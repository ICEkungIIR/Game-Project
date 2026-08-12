extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/saved_world.tscn")


func _on_credits_pressed() -> void:
	# TODO: Credits.tscn doesn't exist yet — build it, then set the path here.
	print("Credits scene not built yet")


func _on_setting_pressed() -> void:
	# TODO: Setting.tscn doesn't exist yet — build it, then set the path here.
	print("Setting scene not built yet")


func _on_exit_pressed() -> void:
	get_tree().quit()
