extends Node

## Autoload singleton: QuotaManager
## Add as Autoload named "Quota" in Project Settings.
##
## Core end-game loop: the player must have QUOTA_AMOUNTS[cycle] saved up
## in their wallet by the end of each 3-month (84-day) cycle. Meeting it
## pays the quota (deducted from Money) and starts the next, larger
## cycle. Missing it ends the game in defeat. Paying all 4 cycles ends
## the game in victory ("debt paid off").
##
## No UI yet — this just emits signals and freezes TimeM's clock on
## game over/win. A teammate is building the end-game screens; wire them
## to game_over/game_won/quota_paid/quota_failed/quota_due_soon.

signal quota_due_soon(days_left: int)
signal quota_paid(cycle_number: int, amount_paid: int)
signal quota_failed(cycle_number: int, quota_amount: int)
signal game_over
signal game_won

const DAYS_PER_MONTH: int = 28
const MONTHS_PER_CYCLE: int = 3
const DAYS_PER_CYCLE: int = DAYS_PER_MONTH * MONTHS_PER_CYCLE  # 84

## quota_day HUD display steps through these checkpoints within a cycle
## (84 / 4 = 21) instead of counting down every single day — e.g. days
## 1-21 show "21", days 22-42 show "42", etc. Resets to the first
## checkpoint as soon as a quota is paid and the next cycle starts.
const QUOTA_DAY_STEP: int = 21

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
	return cycle_start_day + DAYS_PER_CYCLE


func days_until_due(day_number: int) -> int:
	return due_day() - day_number


## Stepped display value for the quota_day HUD label — elapsed days into
## the current cycle, rounded UP to the nearest QUOTA_DAY_STEP checkpoint
## (21/42/63/84), clamped to DAYS_PER_CYCLE. Jumps to the next checkpoint
## only when crossing a 21-day boundary, rather than changing every day.
func quota_day_marker(day_number: int) -> int:
	var elapsed: int = day_number - cycle_start_day + 1
	elapsed = clampi(elapsed, 1, DAYS_PER_CYCLE)
	var step: int = int(ceil(float(elapsed) / QUOTA_DAY_STEP)) * QUOTA_DAY_STEP
	return mini(step, DAYS_PER_CYCLE)


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
		quota_paid.emit(current_cycle, amount)
		if current_cycle >= QUOTA_AMOUNTS.size():
			_end_game(true)
		else:
			current_cycle += 1
			cycle_start_day = TimeM.current_day
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
