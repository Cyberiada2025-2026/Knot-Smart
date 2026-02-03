extends Node3D

enum TimeOfDay {
	DAWN,
	DAY,
	SUNSET,
	NIGHT
}

@export_group("Cycle parameters")
@export var day_length: float = 15 ## day length in real time minutes
@export_range(0, 24) var dawn_start: float = 5.0 ## hour that dawn starts on. Dawn is considered night mechanics-wise
@export_range(0, 24) var day_start: float = 6.0 ## hour that day starts on. Affects when the day_started signal is sent
@export_range(0, 24) var sunset_start: float = 19.0 ## hour that sunset starts on. Sunset is considered day mechanics-wise
@export_range(0, 24) var night_start: float = 20.0 ## hour that night starts on. Affects when the night_started signal is sent
@export_range(0,24) var initial_hour: float = 7.0 ## hour that the cycle is started on. Affects the day counter and the initial sun postion.

@export_group("Color correction")
@export var LUT_day: Texture3D
@export var LUT_sunset: Texture3D
@export var LUT_night: Texture3D

@export_group("Refs")
@export var world_environment: WorldEnvironment
@export var sun: DirectionalLight3D
@export var day_timer: Timer

var curr_day: int = 0
var time_of_day: TimeOfDay:
	set(value):
		time_of_day = value
		match value:
			TimeOfDay.DAY:
				world_environment.environment.adjustment_color_correction = LUT_day
				day_started.emit()
			TimeOfDay.SUNSET:
				world_environment.environment.adjustment_color_correction = LUT_sunset
				sunset_started.emit()
			TimeOfDay.NIGHT:
				world_environment.environment.adjustment_color_correction = LUT_night
				night_started.emit()
			TimeOfDay.DAWN:
				world_environment.environment.adjustment_color_correction = LUT_sunset
				dawn_started.emit()

signal dawn_started
signal day_started
signal sunset_started
signal night_started

func day_length_seconds() -> float:
	return day_length * 60.0

func hour_to_sun_rotation(hour: float) -> float:
	var hour_normalized = hour/24
	return hour_normalized * -2*PI + PI/2

func time_to_hour(time: float) -> float:
	return fmod((1 - time/day_length_seconds()) * 24 + initial_hour, 24)

func _ready() -> void:
	sun.rotation.x = hour_to_sun_rotation(initial_hour)
	time_of_day = hour_to_time_of_day(initial_hour)
	day_timer.wait_time = day_length_seconds()
	day_timer.start()

func hour_to_time_of_day(hour: float) -> TimeOfDay:
	if hour < dawn_start or hour >= night_start:
		return TimeOfDay.NIGHT
	if hour >= dawn_start and hour < day_start:
		return TimeOfDay.DAWN
	if hour >= day_start and hour < sunset_start:
		return TimeOfDay.DAY
	return TimeOfDay.SUNSET
	
func _process(_delta: float) -> void:
	var curr_hour = time_to_hour(day_timer.time_left)

	check_time_of_day_change(curr_hour)
	prints(curr_hour, time_of_day)
		
	sun.rotation.x = hour_to_sun_rotation(curr_hour)

func check_time_of_day_change(curr_hour: float):
	var new_time_of_day = hour_to_time_of_day(curr_hour)
	if new_time_of_day != time_of_day:
		time_of_day = new_time_of_day


func _on_day_timer_timeout() -> void:
	curr_day+=1
