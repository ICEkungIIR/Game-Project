extends Node2D
## Attached to the World scene root. Connects to CraftManager signals so you
## can see crafting feedback in the Output panel while there's no UI yet.
## Swap the print() calls for real UI updates later (toast, inventory panel, etc).
##
## Also connects to Quota.game_won and Quota.game_over: once all 4 quota
## cycles are paid off, switches to ending.tscn (win video); if a quota is
## ever missed, switches to loose_ending.tscn (lose video) instead.

@onready var quota_popup: CanvasLayer = $QuotaPopup

func _ready() -> void:
	Craft.crafted.connect(_on_crafted)
	Craft.craft_failed.connect(_on_craft_failed)
	Quota.game_won.connect(_on_game_won)
	Quota.game_over.connect(_on_game_over)
	Music.play_track(Music.farm_track)
	Farm.register_ground($Tilemap/GrassLayer, $Tilemap/SoilLayer, $Tilemap/WateredSoilLayer)

	Quota.quota_paid.connect(_on_quota_paid)
	#Quota.game_won.connect(_on_game_won)
	#Quota.game_over.connect(_on_game_over)

func _on_crafted(recipe_id: String, amount: int) -> void:
	print("Crafted %s x%d" % [recipe_id, amount])

func _on_craft_failed(recipe_id: String, missing_item: String) -> void:
	print("Failed to craft %s — missing %s" % [recipe_id, missing_item])

func _on_quota_paid(cycle_number: int, amount_paid: int) -> void:
	print("QUOTA PAID SIGNAL FIRED: cycle=%d amount=%d" % [cycle_number, amount_paid])
	quota_popup.show_popup(cycle_number, amount_paid)

func _on_game_won() -> void:
	Transition.fade_to_scene("res://scenes/win_scene.tscn")

func _on_game_over() -> void:
	Music.stop()
	Transition.fade_to_scene("res://scenes/lose_ending.tscn")
