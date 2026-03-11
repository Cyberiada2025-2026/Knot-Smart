@tool
extends WorldEnvironment

func _ready() -> void:
	var day_night_cycle = get_tree().get_nodes_in_group("day_night_cycle").get(0) as DayNightCycle
	if day_night_cycle != null:
		environment.adjustment_enabled = true
		_on_new_time_of_day(day_night_cycle.current_time_of_day)
		day_night_cycle.time_of_day_started.connect(_on_new_time_of_day)


func _on_new_time_of_day(new: TimeOfDay) -> void:
	environment.adjustment_color_correction = new.color_lut
