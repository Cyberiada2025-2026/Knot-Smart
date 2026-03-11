@tool
extends Node3D

@export_group("Cycle parameters")
@export var times_of_day: Array[TimeOfDay] = []
## Goes from beginning of the day to the end of the day.
@export_range(0, 1) var initial_time: float = 0.0

@export_group("Refs")
@export var sun: DirectionalLight3D
@export var timer: Timer

@onready var environment: Environment = get_viewport().get_camera_3d().environment
var day_duration: float 

var curr_day: int = 0
var curr_time_of_day: TimeOfDay:
	set(value):
		curr_time_of_day = value
		environment.adjustment_color_correction = value.color_lut
		time_of_day_started.emit(value.name)
		print("%s started" % value.name)

signal time_of_day_started(name: String)

func _ready() -> void:
	environment.adjustment_enabled = true

	day_duration = times_of_day.reduce(func(a: float, t: TimeOfDay): return a + t.duration, 0.0) 

	timer.wait_time = day_duration

	#time_of_day = hour_to_time_of_day(initial_hour)
	#day_timer.wait_time = day_length_seconds()

	

func _on_day_timer_timeout() -> void:
	curr_day+=1
