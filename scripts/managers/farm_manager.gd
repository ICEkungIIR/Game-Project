extends Node2D

## Autoload singleton: FarmManager
## Add as Autoload named "Farm" in Project Settings.
## Tracks soil state per grid cell (tilled/watered) and renders simple
## placeholder overlays until real tilled/wet-dirt tile art exists.
## world.gd calls register_ground() in its _ready() to hook up the layer.

enum State { EMPTY, TILLED, WATERED }

signal tile_changed(cell: Vector2i, state: int)

const TILLED_COLOR := Color(0.36, 0.25, 0.16, 1.0)
const WATERED_COLOR := Color(0.20, 0.13, 0.08, 1.0)

var ground: TileMapLayer = null

var _state: Dictionary = {}     # Vector2i -> State
var _overlays: Dictionary = {}  # Vector2i -> Sprite2D
var _tilled_tex: ImageTexture
var _watered_tex: ImageTexture


func register_ground(layer: TileMapLayer) -> void:
	ground = layer
	var size: Vector2i = layer.tile_set.tile_size
	_tilled_tex = _make_flat_texture(TILLED_COLOR, size)
	_watered_tex = _make_flat_texture(WATERED_COLOR, size)


func _ready() -> void:
	TimeM.day_started.connect(_on_day_started)


func get_state(cell: Vector2i) -> int:
	return _state.get(cell, State.EMPTY)


func world_to_cell(world_pos: Vector2) -> Vector2i:
	return ground.local_to_map(ground.to_local(world_pos)) if ground else Vector2i.ZERO


func cell_to_world(cell: Vector2i) -> Vector2:
	return ground.to_global(ground.map_to_local(cell)) if ground else Vector2.ZERO


## Valid till target: a real Ground tile exists there and it's untouched.
func is_tillable(cell: Vector2i) -> bool:
	if ground == null or ground.get_cell_source_id(cell) == -1:
		return false
	return get_state(cell) == State.EMPTY


## Valid water target: cell has been tilled and isn't already watered.
func is_waterable(cell: Vector2i) -> bool:
	return get_state(cell) == State.TILLED


func till(cell: Vector2i) -> bool:
	if not is_tillable(cell):
		return false
	_state[cell] = State.TILLED
	_update_overlay(cell)
	tile_changed.emit(cell, State.TILLED)
	return true


func water(cell: Vector2i) -> bool:
	if not is_waterable(cell):
		return false
	_state[cell] = State.WATERED
	_update_overlay(cell)
	tile_changed.emit(cell, State.WATERED)
	return true


## Watered soil dries back to tilled (not empty) at the start of each day.
func _on_day_started(_day_number: int) -> void:
	for cell in _state.keys():
		if _state[cell] == State.WATERED:
			_state[cell] = State.TILLED
			_update_overlay(cell)
			tile_changed.emit(cell, State.TILLED)


func _update_overlay(cell: Vector2i) -> void:
	var state: int = get_state(cell)
	if state == State.EMPTY:
		if _overlays.has(cell):
			_overlays[cell].queue_free()
			_overlays.erase(cell)
		return

	var sprite: Sprite2D = _overlays.get(cell)
	if sprite == null:
		sprite = Sprite2D.new()
		add_child(sprite)
		_overlays[cell] = sprite
	sprite.texture = _tilled_tex if state == State.TILLED else _watered_tex
	sprite.global_position = cell_to_world(cell)


func _make_flat_texture(color: Color, size: Vector2i) -> ImageTexture:
	var img := Image.create(max(size.x, 1), max(size.y, 1), false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
