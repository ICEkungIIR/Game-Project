extends TextureButton


# ==========================================
# SETTINGS
# ==========================================

@export var hover_scale := 1.05
@export var pressed_scale := 0.90

@export var hover_duration := 0.12
@export var pressed_duration := 0.08

@export var hover_color := Color(1.25, 1.25, 1.25, 1.0)
@export var pressed_color := Color(0.85, 0.85, 0.85, 1.0)


# ==========================================
# VARIABLES
# ==========================================

var normal_scale: Vector2
var tween: Tween


# ==========================================
# READY
# ==========================================

func _ready() -> void:
	normal_scale = scale

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


# ==========================================
# HOVER
# ==========================================

func _on_mouse_entered() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# ขยายปุ่ม
	tween.tween_property(
		self,
		"scale",
		normal_scale * hover_scale,
		hover_duration
	)

	# สว่างขึ้น
	tween.parallel().tween_property(
		self,
		"modulate",
		hover_color,
		hover_duration
	)


# ==========================================
# MOUSE EXIT
# ==========================================

func _on_mouse_exited() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# กลับขนาดปกติ
	tween.tween_property(
		self,
		"scale",
		normal_scale,
		hover_duration
	)

	# กลับสีปกติ
	tween.parallel().tween_property(
		self,
		"modulate",
		Color.WHITE,
		hover_duration
	)


# ==========================================
# BUTTON DOWN
# ==========================================

func _on_button_down() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# ยุบปุ่ม
	tween.tween_property(
		self,
		"scale",
		normal_scale * pressed_scale,
		pressed_duration
	)

	# ทำให้มืดลงนิดหนึ่ง
	tween.parallel().tween_property(
		self,
		"modulate",
		pressed_color,
		pressed_duration
	)


# ==========================================
# BUTTON UP
# ==========================================

func _on_button_up() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	# เด้งกลับ
	tween.tween_property(
		self,
		"scale",
		normal_scale * hover_scale,
		0.18
	)

	# กลับเป็นสีตอน Hover
	tween.parallel().tween_property(
		self,
		"modulate",
		hover_color,
		0.18
	)
