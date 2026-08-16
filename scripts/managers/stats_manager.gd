extends Node

## Autoload singleton: StatsManager
## Add as Autoload named "Stats" in Project Settings.
## Holds player health/stamina/mana. HUD bars connect to these signals
## instead of polling every frame.
## Usage: Stats.take_damage(10)  /  Stats.use_stamina(10)  /  Stats.heal(5)

signal health_changed(new_value: float, max_value: float)
signal stamina_changed(new_value: float, max_value: float)
signal mana_changed(new_value: float, max_value: float)

@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var max_mana: float = 100.0

## Passive regen while not otherwise draining stamina/mana (per second).
## Set to 0 to disable regen for a given stat.
@export var stamina_regen_rate: float = 5.0
@export var mana_regen_rate: float = 2.0

var health: float
var stamina: float
var mana: float


func _ready() -> void:
	health = max_health
	stamina = max_stamina
	mana = max_mana


func _process(delta: float) -> void:
	if stamina_regen_rate > 0.0 and stamina < max_stamina:
		restore_stamina(stamina_regen_rate * delta)
	if mana_regen_rate > 0.0 and mana < max_mana:
		restore_mana(mana_regen_rate * delta)


func take_damage(amount: float) -> void:
	health = clamp(health - amount, 0.0, max_health)
	health_changed.emit(health, max_health)


func heal(amount: float) -> void:
	health = clamp(health + amount, 0.0, max_health)
	health_changed.emit(health, max_health)


## Returns false (and spends nothing) if not enough stamina — callers
## should skip the action when this returns false.
func use_stamina(amount: float) -> bool:
	if stamina < amount:
		return false
	stamina -= amount
	stamina_changed.emit(stamina, max_stamina)
	return true


func restore_stamina(amount: float) -> void:
	stamina = clamp(stamina + amount, 0.0, max_stamina)
	stamina_changed.emit(stamina, max_stamina)


func use_mana(amount: float) -> bool:
	if mana < amount:
		return false
	mana -= amount
	mana_changed.emit(mana, max_mana)
	return true


func restore_mana(amount: float) -> void:
	mana = clamp(mana + amount, 0.0, max_mana)
	mana_changed.emit(mana, max_mana)
