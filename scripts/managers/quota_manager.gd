extends Node

## Autoload singleton: QuotaManager
## Add as Autoload named "Quota" in Project Settings.
##
## Core end-game loop: the player must have QUOTA_AMOUNTS[cycle] saved up
## in their wallet by day (cycle_number * DAYS_PER_CYCLE) — a fixed
## schedule of 21/42/63/84. Meeting it pays the quota (deducted from
## Money) and starts the next, larger cycle. Missing it ends the game in
## defeat. Paying all 4 cycles ends the game in victory ("debt paid off").
##
## No UI yet — this just emits signals and freezes TimeM's clock on
## game over/win. Wired in world.gd to ending.tscn / loose_ending.tscn.

signal quota_due_soon(days_left: int)
signal quota_paid(cycle_number: int, amount_paid: int)
signal quota_failed(cycle_number: int, quota_amount: int)
signal game_over
signal game_won

## Length of each quota round, in days. Due dates are a fixed schedule —
## current_cycle * DAYS_PER_CYCLE — so round 1 is due day 21, round 2 day
## 42, round 3 day 63, round 4 (final) day 84.
const DAYS_PER_CYCLE: int = 21

## Fixed quota for each cycle, in order. Cycle 1 = QUOTA_AMOUNTS[0], etc.
## The game is won once the last one is paid.
const QUOTA_AMOUNTS: Array[int] = [1000, 10000, 100000, 1000000]

## How many days out a "due soon" warning fires (once per day in that
## window, since day_started only fires once per day anyway).
const DUE_SOON_WARNING_DAYS: int = 7

var current_cycle: int = 1  # 1-based

var _ended: bool = false


func _ready() -> void:
	TimeM.day_started.connect(_on_day_started)


## Quota amount for the cycle currently in progress.
func current_quota_amount() -> int:
	var index: int = current_cycle - 1
	if index < 0 or index >= QUOTA_AMOUNTS.size():
		return 0
	return QUOTA_AMOUNTS[index]


## Fixed due date for the cycle currently in progress: 21/42/63/84.
func due_day() -> int:
	return current_cycle * DAYS_PER_CYCLE


func days_until_due(day_number: int) -> int:
	return due_day() - day_number


## HUD display value for the "Xd" label — just the current cycle's fixed
## due date (21/42/63/84).
func quota_day_marker(_day_number: int) -> int:
	return due_day()


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
		var completed_cycle: int = current_cycle
		if current_cycle >= QUOTA_AMOUNTS.size():
			quota_paid.emit(completed_cycle, amount)
			_end_game(true)
		else:
			current_cycle += 1
			quota_paid.emit(completed_cycle, amount)
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
