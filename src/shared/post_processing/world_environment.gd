@tool
extends WorldEnvironment


func _ready() -> void:
	var day_night_cycle = get_tree().get_nodes_in_group("day_night_cycle").get(0) as DayNightCycle
	if day_night_cycle != null:
		environment.adjustment_enabled = true
		day_night_cycle.time_period_changed.connect(_on_time_period_changed)


func _on_time_period_changed(new: TimePeriod) -> void:
	if new != null:
		environment.adjustment_color_correction = new.color_lut
