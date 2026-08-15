extends Node

## Autoload singleton: ToolDatabase
## Add as Autoload named "ToolDB" in Project Settings.
## Scans resources/Tools/ on startup and builds a tools_id -> Tools map,
## so any system (hotbar, inventory, shops) can look up icon/price/stats
## from just the item_id string that Inventory stores. Mirrors
## crop_database.gd's pattern exactly.

const TOOLS_PATH := "res://resources/Tools/"

var by_id: Dictionary = {}  # tools_id (String) -> Tools


func _ready() -> void:
	_load_all_tools()


func _load_all_tools() -> void:
	var dir := DirAccess.open(TOOLS_PATH)
	if dir == null:
		push_error("ToolDatabase: could not open %s" % TOOLS_PATH)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var data: Tools = load(TOOLS_PATH + file_name)
			if data and data.tools_id != "":
				by_id[data.tools_id] = data
			else:
				push_warning("ToolDatabase: %s has no tools_id set — fill it in the Inspector" % file_name)
		file_name = dir.get_next()
	dir.list_dir_end()


func get_tool(tools_id: String) -> Tools:
	return by_id.get(tools_id, null)
