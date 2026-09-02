extends Control

## Attach to day_HUD.tscn root (Control).
## Syncs Label with the TimeM autoload (time_manager.gd), and quota_day
## with the Quota autoload (quota_manager.gd) — days left until the
## current quota cycle is due.

@onready var label: Label = $Label
@onready var quota_day_label: Label = $quota_day


func _ready() -> void:
	TimeM.day_started.connect(_on_day_started)
	_on_day_started(TimeM.current_day)


func _on_day_started(day_number: int) -> void:
	$HBoxContainer/current_day.text = "Day %d" % day_number
	$HBoxContainer/quota_day.text = "%dd" % Quota.quota_day_marker(day_number)
