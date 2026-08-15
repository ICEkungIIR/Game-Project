extends Node

## Autoload singleton: CropDatabase
## Add as Autoload named "CropDB" in Project Settings.
## Builds a crop_id -> CropData map from an explicit preload() list, so
## any system (SellUI, shops, etc.) can look up price/name/texture from
## just the item_id string that Inventory stores.
##
## Was previously a runtime DirAccess scan of resources/Crops/ — switched
## to explicit preload() because runtime directory-listing of res:// is a
## fragile pattern across exported builds/platforms (confirmed: worked
## fine in the Godot editor, but this class of bug is exactly why crop/
## tool icons silently failed to show in the exported web build).
## preload() creates a static dependency the exporter always bundles, and
## behaves identically in editor, desktop, and web exports.
##
## Add a new crop: add its .tres path to CROP_RESOURCES below.

const CROP_RESOURCES: Array[CropData] = [
	preload("res://resources/Crops/wheat.tres"),
	preload("res://resources/Crops/carrot.tres"),
	preload("res://resources/Crops/potato.tres"),
	preload("res://resources/Crops/tomato.tres"),
]

var by_id: Dictionary = {}  # crop_id (String) -> CropData


func _ready() -> void:
	_load_all_crops()


func _load_all_crops() -> void:
	for data in CROP_RESOURCES:
		if data and data.crop_id != "":
			by_id[data.crop_id] = data
		else:
			push_warning("CropDatabase: a crop resource has no crop_id set — fill it in the Inspector")


func get_crop(crop_id: String) -> CropData:
	return by_id.get(crop_id, null)
