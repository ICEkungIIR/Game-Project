extends CharacterBody2D
class_name AnimalResource

## Attach to a CharacterBody2D scene for a HARVESTABLE farm animal (e.g. a
## cow/chicken pen animal) — separate from monster.gd, which is for
## CAPTURING wild monsters (they vanish into MonsterPen on success).
## Animals with this script wander around their spawn point (like
## monster.gd) but stay in the world permanently and can be harvested
## repeatedly instead of being captured.
##
## REQUIRED CHILD NODES (build in editor, same pattern as monster.gd):
##   AnimalResource (CharacterBody2D, this script)
##   ├─ Icon (AnimatedSprite2D)     <- SpriteFrames must define
##   │                                 idle_front/back/left/right and
##   │                                 walk_front/back/left/right
##   ├─ CollisionShape2D            <- for physics body itself
##   ├─ InteractArea (Area2D)
##   │   └─ CollisionShape2D         <- detects when player is close enough
##   └─ InteractPrompt (Sprite2D)    <- "press E" hint, same art as Monster's
##
## Press E while in range:
##   - 100% chance: gives product_item_id x product_amount to Inventory
##   - spawn_chance (default 5%): ALSO spawns a duplicate of this animal
##     nearby, as if a new one was "born" — added as a sibling of this
##     animal's own scene root, so pen numbers can grow over time
## Cooldown is cooldown_days in-game days per animal instance, tracked via
## TimeM.current_day — harvesting again before the cooldown resets does
## nothing (no partial/failed feedback yet, matches monster.gd's current
## level of polish — add a real "not ready" indicator later).

@export var product_item_id: String = "milk"
@export var product_amount: int = 1
@export var spawn_chance: float = 0.05
@export var cooldown_days: int = 1
@export var wander_speed: float = 40.0
@export var wander_radius: float = 80.0

var player_inside: bool = false
var _last_harvest_day: int = -999  # far enough in the past to always allow the first harvest
var _home_position: Vector2
var _wander_target: Vector2
var _wander_timer: float = 0.0
var _facing_dir: Vector2 = Vector2.DOWN

@onready var interact_prompt: Sprite2D = $InteractPrompt
@onready var icon: AnimatedSprite2D = $Icon


func _ready() -> void:
	_home_position = global_position
	_pick_new_wander_target()

	var area: Area2D = $InteractArea
	area.body_entered.connect(_on_interact_area_body_entered)
	area.body_exited.connect(_on_interact_area_body_exited)
	interact_prompt.visible = false


func _physics_process(delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_pick_new_wander_target()

	var to_target: Vector2 = _wander_target - global_position
	if to_target.length() > 4.0:
		velocity = to_target.normalized() * wander_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if velocity != Vector2.ZERO:
		_facing_dir = velocity.normalized()
		_play_walk_animation(_facing_dir)
	else:
		_play_idle_animation()


func _play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		icon.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		icon.play("walk_front" if dir.y > 0 else "walk_back")


func _play_idle_animation() -> void:
	if abs(_facing_dir.x) > abs(_facing_dir.y):
		icon.play("idle_right" if _facing_dir.x > 0 else "idle_left")
	else:
		icon.play("idle_front" if _facing_dir.y > 0 else "idle_back")


func _pick_new_wander_target() -> void:
	_wander_target = _home_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
	_wander_timer = randf_range(2.0, 4.0)


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		interact_prompt.visible = _is_ready()


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		interact_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("interact"):
		_try_harvest()


func _is_ready() -> bool:
	return TimeM.current_day - _last_harvest_day >= cooldown_days


func _try_harvest() -> void:
	if not _is_ready():
		return
	_last_harvest_day = TimeM.current_day
	Inventory.add_item(product_item_id, product_amount)
	interact_prompt.visible = false
	Fx.burst(global_position, Color.LIGHT_PINK)

	if randf() <= spawn_chance:
		_spawn_new_animal()


## Walks up to this animal's own instanced-scene root (the node whose
## scene_file_path is set — e.g. cow.tscn's root "cow" Node2D, NOT this
## inner CharacterBody2D), so the duplicate carries the whole scene
## structure correctly regardless of how deep this script sits in it.
func _get_own_scene_root() -> Node:
	var n: Node = self
	while n and n.scene_file_path == "":
		n = n.get_parent()
	return n


func _spawn_new_animal() -> void:
	var scene_root: Node = _get_own_scene_root()
	if scene_root == null or scene_root.get_parent() == null:
		return
	var new_animal: Node = scene_root.duplicate()
	if new_animal is Node2D and scene_root is Node2D:
		new_animal.position = scene_root.position + Vector2(randf_range(-40.0, 40.0), randf_range(-40.0, 40.0))
	scene_root.get_parent().add_child(new_animal)
