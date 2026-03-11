@tool
extends Node3D

@export var times_of_day: Array[TimeOfDay] = []
## Duration in seconds from beginning of day
@export var initial_time: float = 0.0

@onready var environment: Environment = get_viewport().get_camera_3d().environment

var day_duration: float 

var curr_day: int = 0

signal time_of_day_started(name: String)
signal day_ended(curr_day: int)

func start():
	for tod in times_of_day:
		await SceneTree.create_timer(tod.duration)

func _ready() -> void:
	environment.adjustment_enabled = true

	day_duration = times_of_day.reduce(func(a: float, t: TimeOfDay): return a + t.duration, 0.0) 

	curr_time = initial_time

