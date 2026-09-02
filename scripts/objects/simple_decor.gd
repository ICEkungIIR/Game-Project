@tool
extends StaticBody2D
class_name SimpleDecor

## Ported from GodewValley's simple_object.gd (godew-valley reference
## project) — a small reusable decoration object (bush/rock variants)
## using one shared spritesheet (decoration.png, 4 cols x 2 rows: size
## 0-3 across, style Bush/Rock down).
##
## Setter guard: exported property setters fire while Godot deserializes
## the scene, BEFORE child nodes (like $Sprite2D) are added to the tree
## — touching $Sprite2D there hits null. is_node_ready() guards against
## that; _ready() re-applies the correct frame once the node truly is
## ready, so nothing is lost, it's just deferred.

@export_range(0, 3, 1) var size: int:
	set(value):
		size = value
		if is_node_ready():
			$Sprite2D.frame_coords = Vector2i(size, style)
@export_enum('Bush', 'Rock') var style: int:
	set(value):
		style = value
		if is_node_ready():
			$Sprite2D.frame_coords = Vector2i(size, style)
@export var random: bool
@export_tool_button('Randomize', "Callable") var randomizer = randomize


func _ready() -> void:
	if random:
		size = randi_range(0, $Sprite2D.hframes - 1)
		style = [0, 1].pick_random()
	$Sprite2D.frame_coords = Vector2i(size, style)
	$CollisionShape2D.disabled = size < 2
	z_index = -1 if size < 2 else 0


func randomize() -> void:
	size = randi_range(0, $Sprite2D.hframes - 1)
	style = [0, 1].pick_random()
	$Sprite2D.frame_coords = Vector2i(size, style)
