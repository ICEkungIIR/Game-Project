extends Area2D
class_name FarmTile

## Attach to a FarmTile scene (Area2D + Sprite2D + CollisionShape2D), placed
## on each farmable soil tile in the Farm scene. Detects the player standing
## on it and reacts to the "interact" input action.

enum State { EMPTY, TILLED, PLANTED }

@export var crop_scene: PackedScene  # assign Crop.tscn in the Inspector
@export var available_crop: CropData  # which crop this tile plants (swap via a seed-select UI later)

@onready var sprite: Sprite2D = $Sprite2D

var state: State = State.EMPTY
var player_inside: bool = false
var current_crop: Crop = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not player_inside:
		return
	if event.is_action_pressed("interact"):
		_handle_interact()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false


func _handle_interact() -> void:
	match state:
		State.EMPTY:
			_till()
		State.TILLED:
			_plant()
		State.PLANTED:
			if current_crop and current_crop.is_ready:
				_harvest()
			elif current_crop:
				current_crop.water()


func _till() -> void:
	state = State.TILLED
	_update_visual()


func _plant() -> void:
	if not available_crop or not crop_scene:
		return
	current_crop = crop_scene.instantiate()
	current_crop.data = available_crop
	add_child(current_crop)
	state = State.PLANTED
	_update_visual()


func _harvest() -> void:
	if current_crop.harvest():
		current_crop = null
		state = State.TILLED  # ready to plant again right away
		_update_visual()


func _update_visual() -> void:
	# Swap sprite.texture per state (empty/tilled dirt) here once art is in.
	pass
