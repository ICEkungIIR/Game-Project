extends Node2D

## Attached to the World scene root. Connects to CraftManager signals so you
## can see crafting feedback in the Output panel while there's no UI yet.
## Swap the print() calls for real UI updates later (toast, inventory panel, etc).

func _ready() -> void:
	Craft.crafted.connect(_on_crafted)
	Craft.craft_failed.connect(_on_craft_failed)
	Music.play_track(Music.farm_track)
	Farm.register_ground($Tilemap/Ground)


func _on_crafted(recipe_id: String, amount: int) -> void:
	print("Crafted %s x%d" % [recipe_id, amount])


func _on_craft_failed(recipe_id: String, missing_item: String) -> void:
	print("Failed to craft %s — missing %s" % [recipe_id, missing_item])
