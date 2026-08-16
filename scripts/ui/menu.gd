extends Node2D

# อ้างอิงโหนดปุ่มทั้งหมด (ปรับ path ให้ตรงกับ Scene tree จริง)
@onready var btn_newgame: TextureButton = $btnNewgame
@onready var btn_continue: TextureButton = $btnContinue
@onready var btn_setting: TextureButton = $btnSetting
@onready var btn_credit: TextureButton = $btnCredit
@onready var btn_exit: TextureButton = $btnExit


func _ready() -> void:
	# ตั้ง Click Mask ให้ทุกปุ่ม (เช็คจาก alpha ของ texture_normal)
	# แก้ปัญหา hover ติดพื้นที่โปร่งใสรอบขอบรูป
	_apply_click_mask(btn_newgame)
	_apply_click_mask(btn_continue)
	_apply_click_mask(btn_setting)
	_apply_click_mask(btn_credit)
	_apply_click_mask(btn_exit)

	# เชื่อมสัญญาณ pressed ของปุ่มทุกอันด้วยโค้ด (ไม่ต้องเชื่อมผ่าน Inspector)
	btn_newgame.pressed.connect(_on_btn_newgame_pressed)
	btn_continue.pressed.connect(_on_btn_continue_pressed)
	btn_setting.pressed.connect(_on_btn_setting_pressed)
	btn_credit.pressed.connect(_on_btn_credit_pressed)
	btn_exit.pressed.connect(_on_btn_exit_pressed)


func _apply_click_mask(button: TextureButton) -> void:
	if button.texture_normal == null:
		return
	var img: Image = button.texture_normal.get_image()
	if img == null:
		return
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	button.click_mask = bitmap


func _process(delta: float) -> void:
	pass


# ---------- Button Handlers ----------

func _on_btn_newgame_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_btn_continue_pressed() -> void:
	# TODO: เปลี่ยน path เป็นซีนที่ใช้โหลดเซฟจริง ถ้ามีระบบ save/load
	pass


func _on_btn_setting_pressed() -> void:
	# TODO: เปลี่ยน path เป็นซีนหน้า Settings จริง (ถ้ามี)
	pass


func _on_btn_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credit.tscn")


func _on_btn_exit_pressed() -> void:
	get_tree().quit()
