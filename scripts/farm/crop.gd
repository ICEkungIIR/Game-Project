extends Node2D
class_name Crop

## Attach to a Crop scene (Node2D + Sprite2D). Spawned by FarmTile when planted.

@export var data: CropData
@onready var sprite: Sprite2D = $Sprite2D

var growth_days: int = 0
var watered_today: bool = false
var is_ready: bool = false


func _ready() -> void:
	TimeM.day_started.connect(_on_day_started)
	_update_visual()


func water() -> void:
	watered_today = true


func _on_day_started(_day_number: int) -> void:
	if watered_today and not is_ready:
		growth_days += 1
		if growth_days >= data.days_to_grow:
			is_ready = true
	watered_today = false  # crops wilt back to needing water each new day
	_update_visual()


func harvest() -> bool:
	if not is_ready:
		return false
	Inventory.add_item(data.crop_id, data.harvest_yield)
	queue_free()  # tile goes back to empty/tilled after harvest — see farm_tile.gd
	return true


func _update_visual() -> void:
	if data.stage_textures.is_empty():
		return
	var stage_index: int = clampi(growth_days, 0, data.stage_textures.size() - 1)
	sprite.texture = data.stage_textures[stage_index]
