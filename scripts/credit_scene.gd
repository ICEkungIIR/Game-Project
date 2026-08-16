extends Control

func _ready() -> void:
	$AnimationPlayer.play("credit_intro")
	
	# เชื่อมสัญญาณกดปุ่ม BackButton เข้ากับฟังก์ชันย้อนกลับ
	$HeaderBar/BackButton.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	# สั่งเปลี่ยนไปยังหน้า menu.tscn
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
