extends Control


func _ready() -> void:
	# เชื่อมสัญญาณกดปุ่ม BackButton เข้ากับฟังก์ชันย้อนกลับ
	#$BackButton.pressed.connect(_on_back_button_pressed)
	pass
func _on_back_button_pressed() -> void:
	# สั่งเปลี่ยนไปยังหน้า menu.tscn
	Transition.fade_to_scene("res://scenes/menu.tscn")
