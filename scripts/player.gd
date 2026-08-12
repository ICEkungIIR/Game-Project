extends CharacterBody2D

## Basic top-down movement for Tavern of Twilight (Week 1 MVP)

@export var speed: float = 120.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_dir: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	input_dir = input_dir.normalized()

	velocity = input_dir * speed
	move_and_slide()

	if input_dir != Vector2.ZERO:
		facing_dir = input_dir
		_play_walk_animation(input_dir)
	else:
		_play_idle_animation()


func _play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		anim_sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		anim_sprite.play("walk_down" if dir.y > 0 else "walk_up")


func _play_idle_animation() -> void:
	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_sprite.play("idle_right" if facing_dir.x > 0 else "idle_left")
	else:
		anim_sprite.play("idle_down" if facing_dir.y > 0 else "idle_up")


func _ready():
	Inventory.add_item("carrot",3)
	Inventory.add_item("milk",3)
	# TEMP: carrot has no icon yet (no art asset), and "milk" isn't a crop
	# so CropDB can't resolve it at all — using wheat/potato here instead
	# since those already have icon art, just to verify bag+hotbar+drag work.
	Inventory.add_item("wheat", 5)
	Inventory.add_item("potato", 5)
	Inventory.set_hotbar_slot(0, "wheat")
	Inventory.set_hotbar_slot(1, "potato")
	#print(Inventory.items)
	#print(Money.spend(200))
	#print(Money.amount)
	
	
	
	
