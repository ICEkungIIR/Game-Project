extends Node

## Autoload singleton: MonsterPen
## Add as Autoload named "MonsterPen" in Project Settings — points DIRECTLY
## to this .gd file (no scene needed, same as Inventory/Money: pure data,
## no child nodes required).
##
## Tracks captured monsters. Usage: MonsterPen.add_monster("slime")

signal monster_captured(monster_id: String, new_amount: int)

var monsters: Dictionary = {}  # monster_id -> count


func add_monster(monster_id: String, amount: int = 1) -> void:
	monsters[monster_id] = monsters.get(monster_id, 0) + amount
	monster_captured.emit(monster_id, monsters[monster_id])


func get_amount(monster_id: String) -> int:
	return monsters.get(monster_id, 0)
