extends Control

## Attach to health_HUD.tscn root (Control).
## Syncs the ProgressBar with the Stats autoload (stats_manager.gd).

@onready var bar: ProgressBar = $ProgressBar


func _ready() -> void:
	Stats.health_changed.connect(_on_health_changed)
	_on_health_changed(Stats.health, Stats.max_health)


func _on_health_changed(new_value: float, max_value: float) -> void:
	bar.max_value = max_value
	bar.value = new_value
