extends Control

## Attach to stamina_HUD.tscn root (Control).
## Syncs the ProgressBar with the Stats autoload (stats_manager.gd).

@onready var bar: ProgressBar = $ProgressBar


func _ready() -> void:
	Stats.stamina_changed.connect(_on_stamina_changed)
	_on_stamina_changed(Stats.stamina, Stats.max_stamina)


func _on_stamina_changed(new_value: float, max_value: float) -> void:
	bar.max_value = max_value
	bar.value = new_value
