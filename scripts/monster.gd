extends CharacterBody2D
class_name Monster

## Attach to a CharacterBody2D scene, e.g. scenes/monsters/Slime.tscn
## REQUIRED CHILD NODES (build in editor):
##   Monster (CharacterBody2D, this script)
##   ├─ Sprite2D (or AnimatedSprite2D)
##   ├─ CollisionShape2D           <- for physics body itself
##   └─ CaptureArea (Area2D)
##       └─ CollisionShape2D        <- detects when player is close enough
##
## Set monster_id / capture_chance per-instance in the Inspector so the
## SAME script works for slime, bee, etc. — just make one .tscn per
## monster type with different exported values (same pattern as CropData,
## but kept as plain exports here since there's no need for a resource yet).

@export var monster_id: String = "slime"
@export var capture_chance: float = 0.5  # 0.0 - 1.0
@export var wander_speed: float = 40.0
@export var wander_radius: float = 80.0

var player_inside: bool = false
var _home_position: Vector2
var _wander_target: Vector2
var _wander_timer: float = 0.0


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


func _pick_new_wander_target() -> void:
	_wander_target = _home_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
	_wander_timer = randf_range(2.0, 4.0)


func _on_capture_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true


func _on_capture_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false


func _unhandled_input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("interact"):
		_attempt_capture()


func _attempt_capture() -> void:
	if randf() <= capture_chance:
		MonsterPen.add_monster(monster_id)
		queue_free()
	else:
		print("The ", monster_id, " escaped!")  # TODO: hook up real feedback (popup/animation)
