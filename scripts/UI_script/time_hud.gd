extends Control

## Attach to time_HUD.tscn root (Control).
## Syncs the Label with the TimeM autoload's in-day clock (hour/minute).

@onready var label: Label = $Label


func _ready() -> void:
	TimeM.time_changed.connect(_on_time_changed)
	_on_time_changed(TimeM.hour, TimeM.minute)


func _on_time_changed(hour: int, minute: int) -> void:
	label.text = "%02d:%02d" % [hour, minute]
