extends CharacterBody2D
class_name Monster

## Attach to a CharacterBody2D scene, e.g. scenes/monsters/Slime.tscn
## REQUIRED CHILD NODES (build in editor):
##   Monster (CharacterBody2D, this script)
##   ├─ Icon (AnimatedSprite2D)     <- SpriteFrames must define
##   │                                 idle_front/back/left/right and
##   │                                 walk_front/back/left/right
##   ├─ CollisionShape2D           <- for physics body itself
##   └─ CaptureArea (Area2D)
##       └─ CollisionShape2D        <- detects when player is close enough
##
## Set monster_id / capture_chance per-instance in the Inspector so the
## SAME script works for slime, bee, etc. — just make one .tscn per
## monster type with different exported values (same pattern as CropData,
## but kept as plain exports here since there's no need for a resource yet).

@export var monster_id: String = "boar"
@export var capture_chance: float = 0.5  # 0.0 - 1.0
@export var wander_speed: float = 40.0
@export var wander_radius: float = 80.0

var player_inside: bool = false
var _home_position: Vector2
var _wander_target: Vector2
var _wander_timer: float = 0.0
var _facing_dir: Vector2 = Vector2.DOWN

@onready var capture_prompt: Sprite2D = $CapturePrompt
@onready var icon: AnimatedSprite2D = $Icon


func _ready() -> void:
	_home_position = global_position
	_pick_new_wander_target()

	var capture_area: Area2D = $CaptureArea
	capture_area.body_entered.connect(_on_capture_area_body_entered)
	capture_area.body_exited.connect(_on_capture_area_body_exited)


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


func _on_capture_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		capture_prompt.visible = true


func _on_capture_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		capture_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("interact"):
		_attempt_capture()


func _attempt_capture() -> void:
	if randf() <= capture_chance:
		MonsterPen.add_monster(monster_id)
		queue_free()
	else:
		print("The ", monster_id, " escaped!")  # TODO: hook up real feedback (popup/animation)
