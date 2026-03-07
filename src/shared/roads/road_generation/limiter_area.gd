@tool
class_name LimiterArea
extends Node

const HIGHLIGHT_COLOR = Color(1, 1, 0, 1)
const VISUALIZATION_COLOR = Color(0, 0, 1, 1)

## Spot size limits, generated spots in this area will have size between limits. [br][br]
## Max size should be at least 2x bigger than min size [br]
## (values will be corrected automatically)
@export var min_spot_size: Vector2i = Vector2i(3, 3):
	set(value):
		min_spot_size = value
		var new_max_spot_size = max_spot_size
		# this is retarded but it works
		for axis in Utils.Axis2.values():
			if min_spot_size[axis] * 2 > max_spot_size[axis]:
				new_max_spot_size[axis] = min_spot_size[axis] * 2
		if new_max_spot_size != max_spot_size:
			max_spot_size = new_max_spot_size

@export var max_spot_size: Vector2i = Vector2i(10, 10):
	set(value):
		max_spot_size = value
		var new_min_spot_size = min_spot_size
		# this is retarded but it works
		for axis in Utils.Axis2.values():
			if min_spot_size[axis] * 2 > max_spot_size[axis]:
				new_min_spot_size[axis] = int(max_spot_size[axis] / 2.0)
		if new_min_spot_size != min_spot_size:
			min_spot_size = new_min_spot_size

## Area where spot limits will be applied
@export var area_limits: Spot = Spot.new()

func visualize():
	if Engine.is_editor_hint():
		var selection = EditorInterface.get_selection()
		var selected_nodes = selection.get_selected_nodes()

		# easier tracking of currently edited area
		if self in selected_nodes:
			area_limits.visualize(HIGHLIGHT_COLOR)
		else:
			area_limits.visualize(VISUALIZATION_COLOR)
