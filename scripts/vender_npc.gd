extends Area2D
class_name VendorNPC

@onready var prompt_label: TextureRect = $PromptLabel

var player_inside: bool = false

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	print("vendor body_entered: ", body.name, " groups: ", body.get_groups())
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	print("vendor body_exited: ", body.name)
	if body.is_in_group("player"):
		player_inside = false

func _process(_delta: float) -> void:
	# only show the prompt while player is near AND the shop UI isn't already open
	prompt_label.visible = player_inside and not SellUI.is_open

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("interact"):
		SellUI.open()  # actual sell logic now lives in SellUI._sell()
