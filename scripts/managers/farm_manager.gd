extends Node2D

## Autoload singleton: FarmManager
## Add as Autoload named "Farm" in Project Settings.
## Tracks soil state per grid cell (tilled/watered) AND planted crops
## (growth days, watered-today, ready-to-harvest) — a grid-based
## reimplementation of the logic originally sketched in the old
## scripts/farm/crop.gd + farm_tile.gd prototype, now wired into the
## tool-based interact flow player.gd already uses.
##
## Tilled and watered soil are both Sprite2D overlays drawn on top of the
## base ground layer. NOTE: game_tile_set.tres defines a "Tilled Dirt"
## terrain (terrain_set_0), but no atlas tile is actually tagged with it
## yet (confirmed: zero "terrain = 1" tags anywhere in the TileSet) — so
## real terrain painting isn't usable until that's set up in the Godot
## TileSet editor (paint the dirt tiles, assign terrain 1, set peering
## bits). Once that's done, till() can switch back to
## set_cells_terrain_connect() instead of this overlay.
##
## world.gd calls register_ground() in its _ready() to hook up the layer.

enum State { EMPTY, TILLED, WATERED }

signal tile_changed(cell: Vector2i, state: int)
signal crop_planted(cell: Vector2i, crop_id: String)
signal crop_grew(cell: Vector2i, growth_days: int, is_ready: bool)
signal crop_harvested(cell: Vector2i)

const TILLED_COLOR := Color(0.36, 0.25, 0.16, 1.0)
const WATERED_COLOR := Color(0.20, 0.13, 0.08, 1.0)

## Farm is an autoload, added to the scene tree before the world scene
## loads — so its Sprite2D children draw BEHIND everything in world.tscn
## by default tree order, even though is_visible_in_tree() reports true
## (that only checks the visibility flag chain, not draw/occlusion order).
## Explicit z_index forces these above the ground/nature TileMapLayers
## regardless of tree position. Crops sit above soil overlays.
const Z_INDEX_SOIL_OVERLAY: int = 50
const Z_INDEX_CROP_SPRITE: int = 51

## Real tilled/watered soil art, if drawn — drag into the Inspector on
## the Farm node (scenes/managers/farm_manager.tscn). Falls back to the
## flat-color placeholder squares if left empty, so nothing breaks while
## art is still in progress.
@export var tilled_texture: Texture2D
@export var watered_texture: Texture2D

## Extra scale multiplier for soil overlay, tunable in the Inspector on
## the Farm node. Applies on top of the automatic "cover the tile" sizing
## (1.0 = exactly covers the tile; lower shrinks it). Crop scale lives on
## each crop's CropData.display_scale instead — see crop_data.gd — since
## different artists' crop art comes in at different native resolutions.
@export var soil_scale: float = 1.0

var ground: TileMapLayer = null

var _state: Dictionary = {}        # Vector2i -> State
var _overlays: Dictionary = {}     # Vector2i -> Sprite2D (soil color)
var _tilled_tex: Texture2D
var _watered_tex: Texture2D

# Planted-crop tracking, separate from soil state above.
var _crop_id: Dictionary = {}      # Vector2i -> String
var _growth_days: Dictionary = {}  # Vector2i -> int
var _watered_today: Dictionary = {} # Vector2i -> bool
var _is_ready: Dictionary = {}     # Vector2i -> bool
var _crop_sprites: Dictionary = {} # Vector2i -> Sprite2D (crop icon)


func register_ground(layer: TileMapLayer) -> void:
	ground = layer
	var size: Vector2i = layer.tile_set.tile_size
	_tilled_tex = tilled_texture if tilled_texture else _make_flat_texture(TILLED_COLOR, size)
	_watered_tex = watered_texture if watered_texture else _make_flat_texture(WATERED_COLOR, size)
	print("[Farm DEBUG] register_ground: layer=%s tile_size=%s | Farm self: inside_tree=%s visible=%s z_index=%s parent=%s" % [
		layer.name, size, is_inside_tree(), visible, z_index, (str(get_parent().name) if get_parent() else "none")
	])


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


## Valid water target: cell has been tilled (soil not yet watered), OR
## cell has a planted crop that hasn't been watered today.
func is_waterable(cell: Vector2i) -> bool:
	if has_crop(cell):
		return not _watered_today.get(cell, false)
	return get_state(cell) == State.TILLED


func till(cell: Vector2i) -> bool:
	if not is_tillable(cell):
		print("[Farm DEBUG] till(%s) REJECTED — is_tillable=false (ground=%s source_id=%s state=%s)" % [
			cell, ground, (str(ground.get_cell_source_id(cell)) if ground else "no ground"), get_state(cell)
		])
		return false
	_state[cell] = State.TILLED
	_update_overlay(cell)
	tile_changed.emit(cell, State.TILLED)
	print("[Farm DEBUG] till(%s) SUCCESS" % [cell])
	return true


func water(cell: Vector2i) -> bool:
	if not is_waterable(cell):
		return false
	if has_crop(cell):
		_watered_today[cell] = true
		return true
	_state[cell] = State.WATERED
	_update_overlay(cell)
	tile_changed.emit(cell, State.WATERED)
	return true


## --- Planting / growth / harvest -------------------------------------

func has_crop(cell: Vector2i) -> bool:
	return _crop_id.has(cell)


## Valid plant target: tilled soil (watered or not) with no crop on it yet.
func is_plantable(cell: Vector2i) -> bool:
	if has_crop(cell):
		return false
	return get_state(cell) == State.TILLED or get_state(cell) == State.WATERED


func plant(cell: Vector2i, crop_id: String) -> bool:
	if not is_plantable(cell):
		print("[Farm DEBUG] plant(%s, %s) REJECTED — not plantable (state=%s has_crop=%s)" % [cell, crop_id, get_state(cell), has_crop(cell)])
		return false
	var data: CropData = CropDB.get_crop(crop_id)
	if data == null:
		print("[Farm DEBUG] plant(%s, %s) REJECTED — CropDB.get_crop returned null" % [cell, crop_id])
		return false

	_crop_id[cell] = crop_id
	_growth_days[cell] = 0
	_watered_today[cell] = get_state(cell) == State.WATERED
	_is_ready[cell] = false
	_spawn_crop_sprite(cell, data)
	crop_planted.emit(cell, crop_id)
	print("[Farm DEBUG] plant(%s, %s) SUCCESS — icon=%s" % [cell, crop_id, data.icon])
	return true


func is_ready_to_harvest(cell: Vector2i) -> bool:
	return _is_ready.get(cell, false)


func harvest(cell: Vector2i) -> bool:
	if not is_ready_to_harvest(cell):
		return false
	var crop_id: String = _crop_id[cell]
	var data: CropData = CropDB.get_crop(crop_id)
	if data == null:
		return false

	Inventory.add_item(crop_id, data.harvest_yield)
	_clear_crop(cell)
	# Soil goes back to tilled (dry) — ready to plant again right away.
	_state[cell] = State.TILLED
	_update_overlay(cell)
	crop_harvested.emit(cell)
	return true


func _clear_crop(cell: Vector2i) -> void:
	_crop_id.erase(cell)
	_growth_days.erase(cell)
	_watered_today.erase(cell)
	_is_ready.erase(cell)
	if _crop_sprites.has(cell):
		_crop_sprites[cell].queue_free()
		_crop_sprites.erase(cell)


## Watered soil dries back to tilled (not empty) at the start of each day.
## Planted crops that were watered advance one growth day; unwatered crops
## don't grow. watered_today resets for every planted cell either way.
func _on_day_started(_day_number: int) -> void:
	for cell in _state.keys():
		if _state[cell] == State.WATERED:
			_state[cell] = State.TILLED
			_update_overlay(cell)
			tile_changed.emit(cell, State.TILLED)

	for cell in _crop_id.keys().duplicate():
		if _watered_today.get(cell, false) and not _is_ready.get(cell, false):
			var data: CropData = CropDB.get_crop(_crop_id[cell])
			if data:
				_growth_days[cell] += 1
				if _growth_days[cell] >= data.days_to_grow:
					_is_ready[cell] = true
				_update_crop_sprite(cell, data)
				crop_grew.emit(cell, _growth_days[cell], _is_ready[cell])
		_watered_today[cell] = false


func _spawn_crop_sprite(cell: Vector2i, data: CropData) -> void:
	var sprite := Sprite2D.new()
	sprite.global_position = cell_to_world(cell)
	sprite.z_index = Z_INDEX_CROP_SPRITE
	add_child(sprite)
	_crop_sprites[cell] = sprite
	_update_crop_sprite(cell, data)
	print("[Farm DEBUG] _spawn_crop_sprite(%s): pos=%s parent=%s visible_in_tree=%s z_index=%s" % [
		cell, sprite.global_position, sprite.get_parent().name, sprite.is_visible_in_tree(), sprite.z_index
	])


## Uses real per-stage art (CropData.stage_textures) when a crop has it —
## one texture per growth day, swapped in as growth advances. Falls back
## to the crop's single icon texture for crops without stage art yet.
## Scale: CropData.display_scale == 0.0 (default) means AUTO — recomputed
## per texture as tile_size.x / max(width, height), so art from different
## artists at different native resolutions all fit the grid (neither axis
## overshoots) without manual tuning. A positive display_scale overrides.
func _update_crop_sprite(cell: Vector2i, data: CropData) -> void:
	var sprite: Sprite2D = _crop_sprites.get(cell)
	if sprite == null:
		return
	var growth_days: int = _growth_days.get(cell, 0)

	if not data.stage_textures.is_empty():
		var stage_index: int = clampi(growth_days, 0, data.stage_textures.size() - 1)
		sprite.texture = data.stage_textures[stage_index]
		var applied_scale: float = _resolve_crop_scale(data, sprite.texture)
		sprite.scale = Vector2.ONE * applied_scale
		print("[Farm DEBUG] _update_crop_sprite(%s) [stage_textures path] tex_size=%s applied_scale=%s" % [
			cell, sprite.texture.get_size(), applied_scale
		])
		return

	# Placeholder: no stage art yet.
	sprite.texture = data.icon
	var applied_scale: float = _resolve_crop_scale(data, sprite.texture)
	sprite.scale = Vector2.ONE * applied_scale
	print("[Farm DEBUG] _update_crop_sprite(%s) [icon placeholder path] tex=%s tex_size=%s applied_scale=%s visible_in_tree=%s" % [
		cell, sprite.texture, (str(sprite.texture.get_size()) if sprite.texture else "null"), applied_scale, sprite.is_visible_in_tree()
	])


## AUTO (display_scale <= 0.0): tile_size.x / max(texture width, height) —
## keyed off whichever dimension is larger, so neither axis overshoots the
## tile even for tall/thin art (e.g. wheat stalks). Manual override
## otherwise. Recomputed per call since stage art can be a different
## resolution at each growth stage.
func _resolve_crop_scale(data: CropData, tex: Texture2D) -> float:
	if data.display_scale > 0.0:
		return data.display_scale
	if tex == null:
		return 1.0
	var largest_dimension: float = max(tex.get_width(), tex.get_height())
	if largest_dimension <= 0.0:
		return 1.0
	var tile_size: Vector2 = Vector2(ground.tile_set.tile_size) if ground else Vector2(16, 16)
	return tile_size.x / largest_dimension


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
		sprite.z_index = Z_INDEX_SOIL_OVERLAY
		add_child(sprite)
		_overlays[cell] = sprite
	sprite.texture = _tilled_tex if state == State.TILLED else _watered_tex
	sprite.global_position = cell_to_world(cell)

	# Cover the whole tile (no gaps at the edges), even if the source art's
	# aspect ratio doesn't exactly match the tile — better than leaving
	# slivers of grass showing through a soil patch.
	var tile_size: Vector2 = Vector2(ground.tile_set.tile_size) if ground else Vector2(16, 16)
	sprite.scale = Vector2.ONE * _cover_scale(sprite.texture.get_size(), tile_size) * soil_scale
	print("[Farm DEBUG] _update_overlay(%s) state=%s tex=%s tex_size=%s pos=%s scale=%s visible_in_tree=%s parent=%s" % [
		cell, state, sprite.texture, (str(sprite.texture.get_size()) if sprite.texture else "null"),
		sprite.global_position, sprite.scale, sprite.is_visible_in_tree(), sprite.get_parent().name
	])


## Scale that fully covers target_size (may crop slightly on one axis) —
## used for background/ground sprites like soil, where a gap showing the
## tile underneath looks worse than a tiny overflow at the edges.
func _cover_scale(tex_size: Vector2, target_size: Vector2) -> float:
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return 1.0
	return max(target_size.x / tex_size.x, target_size.y / tex_size.y)


func _make_flat_texture(color: Color, size: Vector2i) -> ImageTexture:
	var img := Image.create(max(size.x, 1), max(size.y, 1), false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
