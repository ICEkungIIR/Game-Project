extends Node2D

## Attached to scenes/saved_world.tscn
## Only "world 1" is actually built right now — save system isn't in scope yet,
## so world 2/3 buttons are disabled with a "coming soon" look instead of wired
## to a real scene (per Today's Requirements doc).

@onready var world_1_button: Button = $ButtonManager/Saved_1
@onready var world_2_button: Button = $ButtonManager/Saved_2
@onready var world_3_button: Button = $ButtonManager/Saved_3


func _ready() -> void:
	pass


func _on_saved_1_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/world.tscn")
