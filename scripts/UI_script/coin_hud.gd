extends Control

## Attach to coin_HUD.tscn root (Control).
## Syncs the Label with the Money autoload (money_manager.gd).

@onready var label: Label = $Label


func _ready() -> void:
	Money.money_changed.connect(_on_money_changed)
	_on_money_changed(Money.amount)


func _on_money_changed(new_amount: int) -> void:
	label.text = str(new_amount)
