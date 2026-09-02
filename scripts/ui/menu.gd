extends Node2D
@onready var btn_newgame: TextureButton = $btnNewgame
@onready var btn_continue: TextureButton = $btnContinue
@onready var btn_setting: TextureButton = $btnSetting
@onready var btn_credit: TextureButton = $btnCredit
@onready var btn_exit: TextureButton = $btnExit
@onready var settings_panel: Control = $SettingsPanel

func _ready() -> void:
	_apply_click_mask(btn_newgame)
	_apply_click_mask(btn_continue)
	_apply_click_mask(btn_setting)
	_apply_click_mask(btn_credit)
	_apply_click_mask(btn_exit)
	btn_newgame.pressed.connect(_on_btn_newgame_pressed)
	btn_continue.pressed.connect(_on_btn_continue_pressed)
	btn_setting.pressed.connect(_on_btn_setting_pressed)
	btn_credit.pressed.connect(_on_btn_credit_pressed)
	btn_exit.pressed.connect(_on_btn_exit_pressed)
	settings_panel.hide()

func _apply_click_mask(button: TextureButton) -> void:
	if button.texture_normal == null:
		return
	var img: Image = button.texture_normal.get_image()
	if img == null:
		return
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	button.click_mask = bitmap

func _on_btn_newgame_pressed() -> void:
	Transition.fade_to_scene("res://scenes/newgame_intro.tscn")

func _on_btn_continue_pressed() -> void:
	pass

func _on_btn_setting_pressed() -> void:
	settings_panel.show()

func _on_btn_credit_pressed() -> void:
	Transition.fade_to_scene("res://scenes/credit.tscn")

func _on_btn_exit_pressed() -> void:
	get_tree().quit()
