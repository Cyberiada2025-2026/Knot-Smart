@tool
class_name DayNightCycle
extends Node3D

signal time_period_changed(current: TimePeriod)
signal day_changed(current: int)

## Use if day_duration failed to update.
@export_tool_button("Update day duration") var update_day_duration_action = update_day_duration

## Times of day that constitute one cycle
@export var time_periods: Array[TimePeriod] = [TimePeriod.new()]:
	set(value):
		time_periods = value
		update_day_duration()
		update_configuration_warnings()

@export var current_day: int = 0:
	set(value):
		value = max(value, 0)
		if current_day == value:
			return
		current_day = value
		timestamp = _get_timestamp(current_day, day_seconds)
		day_changed.emit(current_day)
		if debug_log:
			print("Day ", current_day, " started")

@export_range(0, 1) var day_progress: float:
	set(value):
		if value == day_progress:
			return
		day_progress = value
		day_seconds = day_progress * day_duration

@export var day_seconds: float:
	set(value):
		if value == day_seconds:
			return
		day_seconds = clamp(value, 0, day_duration - 0.001)
		day_progress = day_seconds / day_duration
		timestamp = _get_timestamp(current_day, day_seconds)

@export var debug_log: bool = false

## Duration in seconds from beginning of day zero
var timestamp: float = 0.0:
	set(value):
		if timestamp == value:
			return
		timestamp = value
		current_day = timestamp_to_days(timestamp)
		current_time_period = timestamp_to_time_period(timestamp)

var day_duration: float

var current_time_period: TimePeriod:
	set(value):
		if current_time_period == value:
			return
		current_time_period = value
		time_period_changed.emit(current_time_period)
		if debug_log:
			print(current_time_period.name, " time of day started")


func _get_timestamp(day: int, seconds: float):
	return day * day_duration + seconds


func timestamp_to_days(seconds: float) -> int:
	return floor(seconds / day_duration)


## Converts timestamp to seconds relative to the beginning of the current day.
func timestamp_to_relative(_timestamp: float) -> float:
	return fmod(_timestamp, day_duration)


func timestamp_to_time_period(_timestamp: float) -> TimePeriod:
	var time = timestamp_to_relative(_timestamp)
	for time_period in time_periods:
		time -= time_period.duration
		if time <= 0:
			return time_period
	return time_periods.get(-1)


func update_day_duration() -> void:
	day_duration = (
		time_periods
		. filter(func(t): return t != null)
		. reduce(func(a, t): return a + t.duration, 0.0)
	)
	day_seconds = day_seconds


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint() and day_duration > 0.0:
		timestamp += delta


func _init() -> void:
	add_to_group("day_night_cycle")


func _get_configuration_warnings() -> PackedStringArray:
	if time_periods.filter(func(t): return t != null).is_empty():
		return [
			"""Time periods array is empty. \
			This node will not work correctly without at least one non-null time period."""
		]
	if day_duration <= 0.0:
		return ["Ensure day duration is longer than 0."]
	return []
