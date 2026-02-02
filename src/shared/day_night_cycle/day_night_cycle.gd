extends Node3D

@export var day_length: float = 15 ## day length in real time minutes
@export_range(0, 24) var day_start: float = 6.0 ## hour that the day starts on. Affects when the day_started signal is sent
@export_range(0, 24) var night_start: float = 20.0 ## hour that the night starts on. Affects when the night_started signal is sent
@export_range(0,24) var initial_hour: float = 7.0 ## hour that the cycle is started on. Affects the day counter and the initial sun postion.

@export var world_environment: WorldEnvironment
@export var sun: DirectionalLight3D
@export var day_timer: Timer

var curr_day: int = 0
var is_day: bool = true

signal day_started
signal night_started

func day_length_seconds() -> float:
	return day_length * 60.0

func hour_to_sun_rotation(hour: float) -> float:
	var hour_normalized = hour/24
	return hour_normalized * -2*PI + PI/2

func time_to_hour(time: float) -> float:
	return (1 - time/day_length_seconds()) * 24 + initial_hour

func _ready() -> void:
	sun.rotation.x = hour_to_sun_rotation(initial_hour)
	if initial_hour >= day_start and initial_hour <= night_start: 
		is_day = true
	day_timer.wait_time = day_length_seconds()
	day_timer.start()
	
func _process(_delta: float) -> void:
	var curr_hour = time_to_hour(day_timer.time_left)
	if is_day and curr_hour >= night_start:
		is_day = false
		night_started.emit()
	elif not is_day and (curr_hour < night_start and curr_hour >= day_start):
		is_day = true
		day_started.emit()
		
	sun.rotation.x = hour_to_sun_rotation(curr_hour)


func _on_day_timer_timeout() -> void:
	curr_day+=1
