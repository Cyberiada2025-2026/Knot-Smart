@tool
extends Node3D

@export var times_of_day: Array[TimeOfDay] = []
## Duration in seconds from beginning of day
@export var initial_time: float = 0.0

@export var environment: Environment

var day_duration: float 

var curr_day: int = 0

signal time_of_day_started(current: TimeOfDay)
signal new_day_started(curr_day: int)

func start():
	while true:
		for tod in times_of_day:
			time_of_day_started.emit(tod.name)
			environment.adjustment_color_correction = tod.color_lut
			print(tod.name, " started")
			await get_tree().create_timer(tod.duration).timeout

		curr_day += 1
		new_day_started.emit(curr_day)
		print("Day ", curr_day, " started")

func _ready() -> void:
	environment.adjustment_enabled = true

	day_duration = times_of_day.reduce(func(a: float, t: TimeOfDay): return a + t.duration, 0.0) 
	
	if not Engine.is_editor_hint():
		start()
