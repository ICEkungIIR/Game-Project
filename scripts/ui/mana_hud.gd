extends Control

## Attach to mana_HUD.tscn root (Control).
## Syncs the ProgressBar with the Stats autoload (stats_manager.gd).

@onready var bar: ProgressBar = $ProgressBar


func _ready() -> void:
	Stats.mana_changed.connect(_on_mana_changed)
	_on_mana_changed(Stats.mana, Stats.max_mana)


func _on_mana_changed(new_value: float, max_value: float) -> void:
	bar.max_value = max_value
	bar.value = new_value
