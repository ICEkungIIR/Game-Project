extends CharacterBody2D

## Top-down movement + tool-action animations for Tavern of Twilight

@export var speed: float = 120.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tile_highlight: Node2D = $TileHighlight

var facing_dir: Vector2 = Vector2.DOWN
var is_performing_action: bool = false

## Maps hotbar item_id -> animation prefix. Placeholder ids — rename keys
## here to match your real tool item ids once they exist in Inventory.
const TOOL_ANIMATIONS := {
	"hoe": "tiling",
	"watering_can": "watering",
	"pickaxe": "mining",
	"axe": "chopping",
}

## Tool sound effects — drag .mp3/.wav/.ogg files into these slots in the
## Inspector. Leave empty for tools that don't have a sound yet.
@export var tiling_sfx: AudioStream
@export var watering_sfx: AudioStream
@export var mining_sfx: AudioStream
@export var chopping_sfx: AudioStream

var _action_sfx: Dictionary = {}

## Which tool-action prefixes affect farm soil, and what Farm method to call.
const FARM_ACTIONS := {
	"tiling": "till",
	"watering": "water",
}

## Stamina cost per farm action (till/water). Applies before the action
## runs — if stamina is too low, the action is skipped entirely.
const FARM_ACTION_STAMINA_COST: float = 5.0


func _process(_delta: float) -> void:
	_update_tile_highlight()


func _physics_process(_delta: float) -> void:
	if is_performing_action:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	input_dir = input_dir.normalized()

	velocity = input_dir * speed
	move_and_slide()

	if input_dir != Vector2.ZERO:
		facing_dir = input_dir
		_play_walk_animation(input_dir)
	else:
		_play_idle_animation()


func _unhandled_input(event: InputEvent) -> void:
	# TEMP debug keys for the new Stats autoload — confirm health/stamina
	# HUD bars update live. Remove once the stat system is confirmed working
	# and real damage/stamina sources (combat, dodge, farm actions) exist.
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
			Stats.take_damage(10.0)
		elif event.keycode == KEY_J:
			Stats.use_stamina(10.0)
		elif event.keycode == KEY_K:
			TimeM.next_day()  # skip a day to watch crop growth without waiting

	if is_performing_action:
		return
	if event.is_action_pressed("interact"):
		_try_use_tool()


func _try_use_tool() -> void:
	var target_cell: Vector2i = _get_target_cell()

	# Harvesting takes priority over whatever's selected — pressing E on a
	# ripe crop harvests it regardless of the held tool/item, same as the
	# soil-tool interact below.
	if Farm.is_ready_to_harvest(target_cell):
		_try_harvest(target_cell)
		return

	var item_id: String = Inventory.get_selected_item()
	if item_id == "":
		return

	if TOOL_ANIMATIONS.has(item_id):
		var action_prefix: String = TOOL_ANIMATIONS[item_id]
		if FARM_ACTIONS.has(action_prefix):
			if not Stats.use_stamina(FARM_ACTION_STAMINA_COST):
				return  # not enough stamina — no wasted swing
			var success: bool = Farm.call(FARM_ACTIONS[action_prefix], target_cell)
			if not success:
				Stats.restore_stamina(FARM_ACTION_STAMINA_COST)  # refund — invalid target
				return  # invalid target (already tilled/watered, or no ground)
		_play_action_animation(action_prefix)
		return

	# Not a known tool — try planting, if the selected item is a crop.
	_try_plant(item_id, target_cell)


## No planting/harvesting animation exists yet (waiting on the 3rd
## teammate's animation work) — these run instantly with no anim lock.
func _try_plant(item_id: String, target_cell: Vector2i) -> void:
	if CropDB.get_crop(item_id) == null:
		return  # not a plantable item
	if not Farm.is_plantable(target_cell):
		return
	if not Inventory.has_item(item_id, 1):
		return
	if not Stats.use_stamina(FARM_ACTION_STAMINA_COST):
		return

	Inventory.remove_item(item_id, 1)
	if not Farm.plant(target_cell, item_id):
		Inventory.add_item(item_id, 1)          # refund — plant failed
		Stats.restore_stamina(FARM_ACTION_STAMINA_COST)


func _try_harvest(target_cell: Vector2i) -> void:
	if not Stats.use_stamina(FARM_ACTION_STAMINA_COST):
		return
	if not Farm.harvest(target_cell):
		Stats.restore_stamina(FARM_ACTION_STAMINA_COST)  # refund — shouldn't happen


func _play_action_animation(action_prefix: String) -> void:
	var suffix: String = _facing_suffix()
	if suffix == "side":
		anim_sprite.flip_h = facing_dir.x < 0

	var anim_name: String = action_prefix + "_" + suffix
	anim_sprite.play(anim_name)
	is_performing_action = true

	Sfx.play(_action_sfx.get(action_prefix))

	var frame_count: int = anim_sprite.sprite_frames.get_frame_count(anim_name)
	var fps: float = anim_sprite.sprite_frames.get_animation_speed(anim_name)
	var duration: float = float(frame_count) / fps if fps > 0.0 else 0.5

	await get_tree().create_timer(duration).timeout
	is_performing_action = false
	_play_idle_animation()


func _play_walk_animation(dir: Vector2) -> void:
	var suffix: String = _dir_suffix(dir)
	if suffix == "side":
		anim_sprite.flip_h = dir.x < 0
	anim_sprite.play("walk_" + suffix)


func _play_idle_animation() -> void:
	var suffix: String = _facing_suffix()
	if suffix == "side":
		anim_sprite.flip_h = facing_dir.x < 0
	anim_sprite.play("idle_" + suffix)


func _facing_suffix() -> String:
	return _dir_suffix(facing_dir)


## The single grid cell directly in front of the player (cardinal only,
## no diagonals — matches the back/front/side sprite facing). Always one
## tile away, so always inside the 3x3 area centered on the player.
func _get_target_cell() -> Vector2i:
	var offset: Vector2i
	if abs(facing_dir.x) > abs(facing_dir.y):
		offset = Vector2i(sign(facing_dir.x), 0)
	else:
		offset = Vector2i(0, sign(facing_dir.y))
	return Farm.world_to_cell(global_position) + offset


## Shows/positions the glowing target-tile square: visible only while a
## tile-affecting tool (hoe/watering can) is selected.
func _update_tile_highlight() -> void:
	if Farm.ground == null:
		tile_highlight.visible = false
		return

	var item_id: String = Inventory.get_selected_item()
	var action_prefix: String = TOOL_ANIMATIONS.get(item_id, "")
	var is_tile_tool: bool = FARM_ACTIONS.has(action_prefix)
	var is_plantable_item: bool = CropDB.get_crop(item_id) != null
	if not is_tile_tool and not is_plantable_item:
		tile_highlight.visible = false
		return

	tile_highlight.square_size = Vector2(Farm.ground.tile_set.tile_size)
	tile_highlight.global_position = Farm.cell_to_world(_get_target_cell())
	tile_highlight.visible = true


## "side" for left/right movement (mirrored via flip_h), "back" for facing
## up/away from camera, "front" for facing down/toward camera.
func _dir_suffix(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "side"
	return "back" if dir.y < 0 else "front"


func _ready():
	_action_sfx = {
		"tiling": tiling_sfx,
		"watering": watering_sfx,
		"mining": mining_sfx,
		"chopping": chopping_sfx,
	}

	Inventory.add_item("carrot",3)
	Inventory.add_item("milk",3)
	# TEMP: carrot has no icon yet (no art asset), and "milk" isn't a crop
	# so CropDB can't resolve it at all — using wheat/potato here instead
	# since those already have icon art, just to verify bag+hotbar+drag work.
	Inventory.add_item("wheat", 5)
	Inventory.add_item("potato", 5)
	Inventory.set_hotbar_slot(0, "wheat")
	Inventory.set_hotbar_slot(1, "potato")

	# TEMP: seed a hoe + watering can so the full till -> plant -> water ->
	# harvest loop can be tested via interact (E) — remove once tools are
	# wired into the real item system.
	Inventory.add_item("hoe", 1)
	Inventory.set_hotbar_slot(2, "hoe")
	Inventory.add_item("watering_can", 1)
	Inventory.set_hotbar_slot(3, "watering_can")

	# TEMP: seed the rest of ToolDB's tools too, just to verify their icons
	# render correctly in the bag/hotbar now that ToolDB is wired in. axe
	# and pickaxe have actions (chopping/mining) but nothing to swing at
	# yet; shovel and sword aren't wired to any action at all.
	Inventory.add_item("axe", 1)
	Inventory.add_item("pickaxe", 1)
	Inventory.add_item("shovel", 1)
	Inventory.add_item("sword", 1)
	Inventory.set_hotbar_slot(4, "axe")
	Inventory.set_hotbar_slot(5, "pickaxe")
	Inventory.set_hotbar_slot(6, "shovel")
	Inventory.set_hotbar_slot(7, "sword")
	#print(Inventory.items)
	#print(Money.spend(200))
	#print(Money.amount)
	
	
	
	
