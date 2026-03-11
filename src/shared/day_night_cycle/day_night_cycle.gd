@tool
extends Node3D

## Times of day that constitute one cycle
@export var times_of_day: Array[TimeOfDay] = []:
	set(value):
		times_of_day = value
		day_duration = times_of_day.reduce(func(a: float, t: TimeOfDay): return a + t.duration, 0.0) 

## Duration in seconds from beginning of day zero
@export var seconds_since_start: float = 0.0:
	set(value):
		var last_tod: TimeOfDay = get_current_time_of_day()
		var last_day: int = get_current_day()

		seconds_since_start = value

		var curr_tod: TimeOfDay = get_current_time_of_day()
		var curr_day: int = get_current_day()

		if curr_tod != last_tod:
			time_of_day_started.emit(curr_tod)
		if curr_day != last_day:
			new_day_started.emit(curr_day)

@export var environment: Environment

var day_duration: float 


func get_current_day() -> int:
	return floor(seconds_since_start / day_duration)

func get_current_time() -> float:
	return fmod(seconds_since_start, day_duration)

func get_current_time_of_day() -> TimeOfDay:
	var time = get_current_time()
	for tod in times_of_day:
		if time <= 0:
			return tod
		time -= tod.duration
	return times_of_day[-1]
		

signal time_of_day_started(current: TimeOfDay)
signal new_day_started(curr_day: int)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		seconds_since_start += delta

func _ready() -> void:
	environment.adjustment_enabled = true

