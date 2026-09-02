extends CharacterBody2D
class_name AnimalResource

## Attach to a CharacterBody2D scene for a HARVESTABLE farm animal (e.g. a
## cow/chicken pen animal) — separate from monster.gd, which is for
## CAPTURING wild monsters (they vanish into MonsterPen on success).
## Animals with this script stay put and can be harvested repeatedly.
##
## REQUIRED CHILD NODES (build in editor, same pattern as monster.gd):
##   AnimalResource (CharacterBody2D, this script)
##   ├─ Icon (AnimatedSprite2D or Sprite2D)
##   ├─ CollisionShape2D            <- for physics body itself
##   ├─ InteractArea (Area2D)
##   │   └─ CollisionShape2D         <- detects when player is close enough
##   └─ InteractPrompt (Sprite2D)    <- "press E" hint, same art as Monster's
##
## Press E while in range:
##   - 100% chance: gives product_item_id x product_amount to Inventory
##   - spawn_chance (default 5%): ALSO spawns a duplicate of this animal
##     nearby, as if a new one was "born" — added as a sibling of this
##     animal's own scene root, so pen numbers can grow over time
## Cooldown is cooldown_days in-game days per animal instance, tracked via
## TimeM.current_day — harvesting again before the cooldown resets does
## nothing (no partial/failed feedback yet, matches monster.gd's current
## level of polish — add a real "not ready" indicator later).

@export var product_item_id: String = "milk"
@export var product_amount: int = 1
@export var spawn_chance: float = 0.05
@export var cooldown_days: int = 1

var player_inside: bool = false
var _last_harvest_day: int = -999  # far enough in the past to always allow the first harvest

@onready var interact_prompt: Sprite2D = $InteractPrompt


func _ready() -> void:
	var area: Area2D = $InteractArea
	area.body_entered.connect(_on_interact_area_body_entered)
	area.body_exited.connect(_on_interact_area_body_exited)
	interact_prompt.visible = false


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		interact_prompt.visible = _is_ready()


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		interact_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("interact"):
		_try_harvest()


func _is_ready() -> bool:
	return TimeM.current_day - _last_harvest_day >= cooldown_days


func _try_harvest() -> void:
	if not _is_ready():
		return
	_last_harvest_day = TimeM.current_day
	Inventory.add_item(product_item_id, product_amount)
	interact_prompt.visible = false
	Fx.burst(global_position, Color.LIGHT_PINK)

	if randf() <= spawn_chance:
		_spawn_new_animal()


## Walks up to this animal's own instanced-scene root (the node whose
## scene_file_path is set — e.g. boar.tscn's root "boar" Node2D, NOT this
## inner CharacterBody2D), so the duplicate carries the whole scene
## structure correctly regardless of how deep this script sits in it.
func _get_own_scene_root() -> Node:
	var n: Node = self
	while n and n.scene_file_path == "":
		n = n.get_parent()
	return n


func _spawn_new_animal() -> void:
	var scene_root: Node = _get_own_scene_root()
	if scene_root == null or scene_root.get_parent() == null:
		return
	var new_animal: Node = scene_root.duplicate()
	if new_animal is Node2D and scene_root is Node2D:
		new_animal.position = scene_root.position + Vector2(randf_range(-40.0, 40.0), randf_range(-40.0, 40.0))
	scene_root.get_parent().add_child(new_animal)
