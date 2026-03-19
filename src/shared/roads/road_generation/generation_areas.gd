@tool
class_name GenerationAreas
extends Node

## tool button for lazy people
@export_tool_button("Add limiter area") var add_limiter_area = _add_area


func _add_area():
	var area = LimiterArea.new()
	area.name = "LimiterArea"
	self.add_child(area, true)
	area.owner = get_tree().edited_scene_root


func get_limiter_areas():
	var areas: Array[LimiterArea]
	areas.assign(find_children("", "LimiterArea", false))
	return areas
