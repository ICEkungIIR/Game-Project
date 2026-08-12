extends Node

## Autoload singleton: MoneyManager
## Add as Autoload named "Money" in Project Settings.
## Usage: Money.add(50)  /  Money.spend(20)

signal money_changed(new_amount: int)

var amount: int = 100  # starting gold, adjust as needed


func add(value: int) -> void:
	amount += value
	money_changed.emit(amount)


func spend(value: int) -> bool:
	if amount < value:
		return false
	amount -= value
	money_changed.emit(amount)
	return true


func can_afford(value: int) -> bool:
	return amount >= value
