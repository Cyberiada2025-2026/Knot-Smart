extends Resource
class_name TerrainBlueprint

var data: Dictionary[Vector2i, TileInfo] = {}
var world_size: int

func _init(declared_map_size: int = 16) -> void:
	self.world_size = declared_map_size
	generate()

func generate() -> void:
	data.clear()
	for x in world_size:
		for z in world_size:
			var coord = Vector2i(x, z)
			data[coord] = TileInfo.new()
	print("TerrainBlueprint: Created blueprint of size ", world_size)
	
func get_height(coord: Vector2i) -> float:
	if data.has(coord): 
		return data[coord].height
		
	for x in [-1, 0, 1]:
		for z in [-1, 0, 1]:
			var target = coord + Vector2i(x, z)
			if data.has(target):
				return data[target].height
	return 0.0
