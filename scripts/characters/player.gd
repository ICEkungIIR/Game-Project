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
	if is_performing_action:
		return
	if event.is_action_pressed("interact"):
		_try_use_tool()


func _try_use_tool() -> void:
	var item_id: String = Inventory.get_selected_item()
	if item_id == "" or not TOOL_ANIMATIONS.has(item_id):
		return

	var action_prefix: String = TOOL_ANIMATIONS[item_id]

	if FARM_ACTIONS.has(action_prefix):
		var target_cell: Vector2i = _get_target_cell()
		var success: bool = Farm.call(FARM_ACTIONS[action_prefix], target_cell)
		if not success:
			return  # invalid target (already tilled/watered, or no ground) — no wasted swing

	_play_action_animation(action_prefix)


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
	if not FARM_ACTIONS.has(action_prefix):
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

	# TEMP: seed a hoe so the new tiling animation can be tested via
	# interact (E) — remove once tools are wired into the real item system.
	Inventory.add_item("hoe", 1)
	Inventory.set_hotbar_slot(2, "hoe")
	#print(Inventory.items)
	#print(Money.spend(200))
	#print(Money.amount)
	
	
	
	
