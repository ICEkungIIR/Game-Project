extends Control

## Attach to day_HUD.tscn root (Control).
## Syncs Label with the TimeM autoload (time_manager.gd), and quota_day
## with the Quota autoload (quota_manager.gd) — days left until the
## current quota cycle is due.

@onready var current_day_label: Label = $HBoxContainer/current_day
@onready var quota_day_label: Label = $HBoxContainer/quota_day


func _ready() -> void:
	TimeM.day_started.connect(_on_day_started)
	_on_day_started(TimeM.current_day)


func _on_day_started(day_number: int) -> void:
	current_day_label.text = "Day %d" % day_number
	quota_day_label.text = "%dd" % Quota.quota_day_marker(day_number)
