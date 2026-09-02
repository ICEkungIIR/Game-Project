extends Control

## Attach to quota_HUD.tscn root (Control).
## Syncs the Label with the Quota autoload (quota_manager.gd) — shows the
## fixed target amount for the cycle currently in progress. Updates when
## a cycle is paid off and the next (larger) quota begins.

@onready var label: Label = $Label


func _ready() -> void:
	Quota.quota_paid.connect(_on_quota_paid)
	_update_label()


func _on_quota_paid(_cycle_number: int, _amount_paid: int) -> void:
	_update_label()


func _update_label() -> void:
	label.text = str(Quota.current_quota_amount())
