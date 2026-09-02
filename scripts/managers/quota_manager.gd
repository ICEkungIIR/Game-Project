extends Node

## Autoload singleton: QuotaManager
## Add as Autoload named "Quota" in Project Settings.
##
## Core end-game loop: the player must have QUOTA_AMOUNTS[cycle] saved up
## in their wallet by the end of each 21-day cycle. Meeting it pays the
## quota (deducted from Money) and starts the next, larger cycle. Missing
## it — even once — ends the game in defeat immediately. Paying all 4
## cycles (4 x 21 = 84 days total, if never missed) ends the game in
## victory ("debt paid off").
##
## No UI yet — this just emits signals and freezes TimeM's clock on
## game over/win. Wired in world.gd to ending.tscn / loose_ending.tscn.

signal quota_due_soon(days_left: int)
signal quota_paid(cycle_number: int, amount_paid: int)
signal quota_failed(cycle_number: int, quota_amount: int)
signal game_over
signal game_won

## Each quota cycle is checked every 21 days — miss even one and it's
## game over immediately, no grace period.
const DAYS_PER_CYCLE: int = 21

## Fixed quota for each cycle, in order. Cycle 1 = QUOTA_AMOUNTS[0], etc.
## The game is won once the last one is paid.
const QUOTA_AMOUNTS: Array[int] = [1000, 10000, 100000, 1000000]

## How many days out a "due soon" warning fires (once per day in that
## window, since day_started only fires once per day anyway).
const DUE_SOON_WARNING_DAYS: int = 7

var current_cycle: int = 1  # 1-based
var cycle_start_day: int = 1

var _ended: bool = false


func _ready() -> void:
	TimeM.day_started.connect(_on_day_started)


## Quota amount for the cycle currently in progress.
func current_quota_amount() -> int:
	var index: int = current_cycle - 1
	if index < 0 or index >= QUOTA_AMOUNTS.size():
		return 0
	return QUOTA_AMOUNTS[index]


func due_day() -> int:
	return cycle_start_day + DAYS_PER_CYCLE - 1


func days_until_due(day_number: int) -> int:
	return due_day() - day_number


func _on_day_started(day_number: int) -> void:
	if _ended:
		return
	var remaining: int = days_until_due(day_number)
	if remaining <= 0:
		_evaluate_quota()
	elif remaining <= DUE_SOON_WARNING_DAYS:
		quota_due_soon.emit(remaining)


func _evaluate_quota() -> void:
	var amount: int = current_quota_amount()
	if Money.can_afford(amount):
		Money.spend(amount)
		var paid_cycle: int = current_cycle
		if current_cycle >= QUOTA_AMOUNTS.size():
			quota_paid.emit(paid_cycle, amount)
			_end_game(true)
		else:
			current_cycle += 1
			cycle_start_day = TimeM.current_day + 1
			quota_paid.emit(paid_cycle, amount)  # emitted AFTER current_cycle updates, so
			# HUD listeners calling current_quota_amount() during this signal see the
			# NEXT cycle's target, not the one that was just paid off
	else:
		quota_failed.emit(current_cycle, amount)
		_end_game(false)


func _end_game(won: bool) -> void:
	_ended = true
	TimeM.time_paused = true
	if won:
		game_won.emit()
	else:
		game_over.emit()
