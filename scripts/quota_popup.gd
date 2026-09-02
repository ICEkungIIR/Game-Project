extends CanvasLayer

@onready var popup_image: TextureRect = $PopupImage
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

var _showing: bool = false

const FADE_TIME: float = 0.3
const DISPLAY_SECONDS: float = 2.5

func _ready() -> void:
	hide()

func show_popup(_cycle_number: int, _amount_paid: int) -> void:
	if _showing:
		return
	_showing = true

	show()
	popup_image.modulate.a = 0.0
	audio.play()

	var tween: Tween = create_tween()
	tween.tween_property(popup_image, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(DISPLAY_SECONDS)
	tween.tween_property(popup_image, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_on_popup_finished)

func _on_popup_finished() -> void:
	hide()
	_showing = false
