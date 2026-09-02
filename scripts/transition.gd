extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	color_rect.modulate.a = 0.0

func fade_to_scene(scene_path: String, duration: float = 0.5):
	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished
	
	# เปลี่ยนฉาก
	get_tree().change_scene_to_file(scene_path)
	
	# Fade กลับมาโปร่งใส
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween2.finished
