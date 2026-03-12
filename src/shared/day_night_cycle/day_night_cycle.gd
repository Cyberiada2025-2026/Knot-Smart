@tool
class_name DayNightCycle
extends Node3D

signal time_of_day_changed(current: TimeOfDay)
signal day_changed(current: int)

## Times of day that constitute one cycle
@export var times_of_day: Array[TimeOfDay] = []:
	set(value):
		times_of_day = value
		day_duration = (
			times_of_day
			. filter(func(t): return t != null)
			. reduce(func(a, t): return a + t.duration, 0.0)
		)
		update_configuration_warnings()

## Duration in seconds from beginning of day zero
@export var seconds_since_start: float = 0.0:
	set(value):
		seconds_since_start = value
		current_day = seconds_to_day(seconds_since_start)
		current_time_of_day = seconds_to_time_of_day(seconds_since_start)

@export var debug_log: bool = false

var day_duration: float

var current_time_of_day: TimeOfDay:
	set(value):
		if current_time_of_day == value:
			return
		current_time_of_day = value
		time_of_day_changed.emit(current_time_of_day)
		if debug_log:
			print(current_time_of_day.name, " time of day started")

var current_day: int = -1:
	set(value):
		if current_day == value:
			return
		current_day = value
		day_changed.emit(current_day)
		if debug_log:
			print("Day ", current_day, " started")


func seconds_to_day(seconds: float) -> int:
	return floor(seconds / day_duration)


func seconds_to_time(seconds: float) -> float:
	return fmod(seconds, day_duration)


func seconds_to_time_of_day(seconds: float) -> TimeOfDay:
	var time = seconds_to_time(seconds)
	for tod in times_of_day:
		time -= tod.duration
		if time <= 0:
			return tod
	return times_of_day.get(-1)


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		seconds_since_start += delta


func _init() -> void:
	add_to_group("day_night_cycle")


func _get_configuration_warnings() -> PackedStringArray:
	if times_of_day.filter(func(t): return t != null).is_empty():
		return [
			"""Times of day array is empty. \
			This node will not work correctly without at least one non-null time of day."""
		]
	return []
