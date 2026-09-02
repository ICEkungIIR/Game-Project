extends Sprite2D

## Tree canopy occlusion fade. GodewValley itself has no tree-specific
## code for this — its equivalent technique is house.gd's roof fade
## (Area2D enter/exit -> tween modulate:a) applied when the player walks
## into a house. Ported that same technique here, applied to trees
## instead: fades the tree semi-transparent while the player overlaps
## its canopy footprint, so the player stays visible instead of being
## fully hidden behind it.

@export var faded_alpha: float = 0.4
@export var fade_duration: float = 0.3


func _on_occlusion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", faded_alpha, fade_duration)


func _on_occlusion_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 1.0, fade_duration)
