@tool
extends WorldEnvironment


func _ready() -> void:
	var day_night_cycle = get_tree().get_nodes_in_group("day_night_cycle").get(0) as DayNightCycle
	if day_night_cycle != null:
		environment.adjustment_enabled = true
		day_night_cycle.time_of_day_changed.connect(_on_time_of_day_changed)


func _on_time_of_day_changed(new: TimeOfDay) -> void:
	environment.adjustment_color_correction = new.color_lut
