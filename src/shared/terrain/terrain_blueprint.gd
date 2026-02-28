extends Resource
class_name TerrainBlueprint

var grid_data: Dictionary = {}
var map_size: int

func _init(declared_map_size: int = 16) -> void:
	self.map_size = declared_map_size
	_generate_empty_grid()

func _generate_empty_grid() -> void:
	grid_data.clear()
	for x in map_size:
		for z in map_size:
			var coord = Vector2i(x, z)
			grid_data[coord] = create_cell()
	print("TerrainBlueprint: Created typed grid of size ", map_size)

func create_cell(height: float = 0.0, type: String = "empty", can_place: String = "any") -> Dictionary:
	return {
		"height": height,
		"type": type,
		"can_place": can_place,
	}
	
func set_cell_value(coord: Vector2i, key: String, value: Variant) -> void:
	if grid_data.has(coord):
		if grid_data[coord].has(key):
			grid_data[coord][key] = value
		else:
			push_error("TerrainBlueprint: Key '%s' does not exist in cell data." % key)
	else:
		push_warning("TerrainBlueprint: Coord %s out of bounds." % str(coord))
		
func add_cell_values(coord: Vector2i, extra_data: Dictionary) -> void:
	if grid_data.has(coord):
		# merge(data, overwrite=true) adds new keys and updates existing ones
		grid_data[coord].merge(extra_data, true)
	else:
		push_warning("TerrainBlueprint: Cannot add data to OOB coord %s" % str(coord))
