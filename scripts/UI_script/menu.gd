extends Node2D

func _ready() -> void:
	# เชื่อมสัญญาณ pressed ของปุ่มด้วยโค้ด (เผื่อยังไม่ได้เชื่อมผ่าน Inspector)
	$UI/btnNewgame.pressed.connect(_on_btn_newgame_pressed)


func _on_btn_newgame_pressed() -> void:
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _process(delta: float) -> void:
	pass
