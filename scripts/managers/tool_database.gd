extends Node

## Autoload singleton: ToolDatabase
## Add as Autoload named "ToolDB" in Project Settings.
## Builds a tools_id -> Tools map from an explicit preload() list, so any
## system (hotbar, inventory, shops) can look up icon/price/stats from
## just the item_id string that Inventory stores.
##
## Was previously a runtime DirAccess scan of resources/Tools/ — switched
## to explicit preload() because runtime directory-listing of res:// is a
## fragile pattern across exported builds/platforms (this class of bug is
## exactly why crop/tool icons silently failed to show in the exported
## web build). preload() creates a static dependency the exporter always
## bundles, and behaves identically in editor, desktop, and web exports.
##
## Add a new tool: add its .tres path to TOOL_RESOURCES below.

const TOOL_RESOURCES: Array[Tools] = [
	preload("res://resources/Tools/hoe.tres"),
	preload("res://resources/Tools/watering_can.tres"),
	preload("res://resources/Tools/axe.tres"),
	preload("res://resources/Tools/pickaxe.tres"),
	preload("res://resources/Tools/shovel.tres"),
	preload("res://resources/Tools/sword.tres"),
]

var by_id: Dictionary = {}  # tools_id (String) -> Tools


func _ready() -> void:
	_load_all_tools()


func _load_all_tools() -> void:
	for data in TOOL_RESOURCES:
		if data and data.tools_id != "":
			by_id[data.tools_id] = data
		else:
			push_warning("ToolDatabase: a tool resource has no tools_id set — fill it in the Inspector")


func get_tool(tools_id: String) -> Tools:
	return by_id.get(tools_id, null)
