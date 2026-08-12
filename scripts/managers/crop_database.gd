extends Node

## Autoload singleton: CropDatabase
## Add as Autoload named "CropDB" in Project Settings.
## Scans resources/Crops/ on startup and builds a crop_id -> CropData map,
## so any system (SellUI, shops, etc.) can look up price/name/texture
## from just the item_id string that Inventory stores.

const CROPS_PATH := "res://resources/Crops/"

var by_id: Dictionary = {}  # crop_id (String) -> CropData


func _ready() -> void:
	_load_all_crops()


func _load_all_crops() -> void:
	var dir := DirAccess.open(CROPS_PATH)
	if dir == null:
		push_error("CropDatabase: could not open %s" % CROPS_PATH)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var data: CropData = load(CROPS_PATH + file_name)
			if data and data.crop_id != "":
				by_id[data.crop_id] = data
			else:
				push_warning("CropDatabase: %s has no crop_id set — fill it in the Inspector" % file_name)
		file_name = dir.get_next()
	dir.list_dir_end()


func get_crop(crop_id: String) -> CropData:
	return by_id.get(crop_id, null)
