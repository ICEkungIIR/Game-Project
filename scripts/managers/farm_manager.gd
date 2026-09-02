extends Node2D

## Autoload singleton: FarmManager
## Add as Autoload named "Farm" in Project Settings.
## Tracks soil state per grid cell (tilled/watered) AND planted crops
## (growth days, watered-today, ready-to-harvest) — a grid-based
## reimplementation of the logic originally sketched in the old
## scripts/farm/crop.gd + farm_tile.gd prototype, now wired into the
## tool-based interact flow player.gd already uses.
##
## Tilled soil is real terrain painting on a dedicated SoilLayer
## TileMapLayer, which has its own standalone TileSet (terrain_set 0,
## terrain 0 = "soil") — adapted directly from GodewValley's soil.png
## terrain setup (same source art, same peering-bit layout, own
## dedicated tileset just like the reference project, rather than
## sharing one tileset with the grass terrain).
##
## Watered soil is a separate dedicated WateredSoilLayer TileMapLayer,
## also its own standalone TileSet using soil_water.png (also adapted
## from GodewValley) — no terrain needed, just one of 3 plain variant
## tiles picked at random per water(), same as the reference project.
## Drying back to tilled just erases the cell on this layer, revealing
## the tilled terrain underneath.
##
## world.gd calls register_ground() in its _ready() to hook up all three
## layers (GrassLayer, SoilLayer, WateredSoilLayer).

enum State { EMPTY, TILLED, WATERED }

signal tile_changed(cell: Vector2i, state: int)
signal crop_planted(cell: Vector2i, crop_id: String)
signal crop_grew(cell: Vector2i, growth_days: int, is_ready: bool)
signal crop_harvested(cell: Vector2i)

## Farm is an autoload, added to the scene tree before the world scene
## loads — so its Sprite2D children (crop sprites) draw BEHIND everything
## in world.tscn by default tree order, even though is_visible_in_tree()
## reports true (that only checks the visibility flag chain, not
## draw/occlusion order). Explicit z_index forces crops above the ground
## TileMapLayers regardless of tree position.
const Z_INDEX_CROP_SPRITE: int = 51

## Matches SoilLayer's own TileSet: terrain_set_0/terrain_0 = "soil".
const TILLED_DIRT_TERRAIN_SET: int = 0
const TILLED_DIRT_TERRAIN: int = 0

## Matches WateredSoilLayer's own TileSet: sources/0 = the soil_water.png
## atlas source (3 plain variant tiles at column 0/1/2, row 0, no terrain).
const WATERED_SOURCE_ID: int = 0
const WATERED_VARIANT_COUNT: int = 3

var ground: TileMapLayer = null
var dirt_layer: TileMapLayer = null
var water_layer: TileMapLayer = null

var _state: Dictionary = {}        # Vector2i -> State

# Planted-crop tracking, separate from soil state above.
var _crop_id: Dictionary = {}      # Vector2i -> String
var _growth_days: Dictionary = {}  # Vector2i -> int
var _watered_today: Dictionary = {} # Vector2i -> bool
var _is_ready: Dictionary = {}     # Vector2i -> bool
var _crop_sprites: Dictionary = {} # Vector2i -> Sprite2D (crop icon)


func register_ground(ground_layer: TileMapLayer, tilled_dirt_layer: TileMapLayer, watered_dirt_layer: TileMapLayer) -> void:
	ground = ground_layer
	dirt_layer = tilled_dirt_layer
	water_layer = watered_dirt_layer


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
		return false
	_state[cell] = State.TILLED
	if dirt_layer:
		dirt_layer.set_cells_terrain_connect([cell], TILLED_DIRT_TERRAIN_SET, TILLED_DIRT_TERRAIN)
	tile_changed.emit(cell, State.TILLED)
	Fx.burst(cell_to_world(cell), Color.SADDLE_BROWN)
	return true


func water(cell: Vector2i) -> bool:
	if not is_waterable(cell):
		return false
	if has_crop(cell):
		_watered_today[cell] = true
		Fx.burst(cell_to_world(cell), Color.DODGER_BLUE)
		return true
	_state[cell] = State.WATERED
	if water_layer:
		water_layer.set_cell(cell, WATERED_SOURCE_ID, Vector2i(randi_range(0, WATERED_VARIANT_COUNT - 1), 0))
	tile_changed.emit(cell, State.WATERED)
	Fx.burst(cell_to_world(cell), Color.DODGER_BLUE)
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
		return false
	var data: CropData = CropDB.get_crop(crop_id)
	if data == null:
		return false

	_crop_id[cell] = crop_id
	_growth_days[cell] = 0
	_watered_today[cell] = get_state(cell) == State.WATERED
	_is_ready[cell] = false
	_spawn_crop_sprite(cell, data)
	crop_planted.emit(cell, crop_id)
	Fx.burst(cell_to_world(cell), Color.FOREST_GREEN)
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
	if get_state(cell) == State.WATERED and water_layer:
		water_layer.erase_cell(cell)
	_state[cell] = State.TILLED
	crop_harvested.emit(cell)
	Fx.burst(cell_to_world(cell), Color.GOLD)
	return true


func _clear_crop(cell: Vector2i) -> void:
	_crop_id.erase(cell)
	_growth_days.erase(cell)
	_watered_today.erase(cell)
	_is_ready.erase(cell)
	if _crop_sprites.has(cell):
		_crop_sprites[cell].queue_free()
		_crop_sprites.erase(cell)


## Watered soil dries back to tilled (not empty) at the start of each day —
## erase the watered_dirt cell so the wet-tile art disappears, leaving the
## already-painted tilled terrain visible underneath. Every planted,
## not-yet-ready crop advances by 1 growth day by default, or by 2 if it
## was watered that day. watered_today resets for every planted cell
## either way.
func _on_day_started(_day_number: int) -> void:
	for cell in _state.keys():
		if _state[cell] == State.WATERED:
			_state[cell] = State.TILLED
			if water_layer:
				water_layer.erase_cell(cell)
			tile_changed.emit(cell, State.TILLED)

	for cell in _crop_id.keys().duplicate():
		if not _is_ready.get(cell, false):
			var data: CropData = CropDB.get_crop(_crop_id[cell])
			if data:
				var step: int = 2 if _watered_today.get(cell, false) else 1
				_growth_days[cell] += step
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
		sprite.scale = Vector2.ONE * _resolve_crop_scale(data, sprite.texture)
		return

	# Placeholder: no stage art yet.
	sprite.texture = data.icon
	sprite.scale = Vector2.ONE * _resolve_crop_scale(data, sprite.texture)


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
