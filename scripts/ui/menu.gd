extends Node2D

func _ready() -> void:
	# เชื่อมสัญญาณ pressed ของปุ่ม New Game
	$UI/btnNewgame.pressed.connect(_on_btn_newgame_pressed)


func _on_btn_newgame_pressed() -> void:
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _process(_delta: float) -> void:
	pass



func _on_btn_exit_pressed() -> void:
	get_tree().quit()
