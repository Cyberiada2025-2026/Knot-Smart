extends Resource
class_name TerrainBlueprint

var data: Dictionary = {}
var world_size: int

enum TileType {EMPTY, ROAD}
enum PlacementRule { 
	FLAT,  
	SLOPE_X, 
	SLOPE_Z, 
	BLOCKED,
}

class TileInfo:
	var height: float
	var type: TileType
	var placement_rule: PlacementRule
	var metadata: Dictionary = {}

	func _init(_h: float = 0.0, _t: TileType = TileType.EMPTY, _p: PlacementRule = PlacementRule.FLAT, _m: Dictionary = {}):
		self.height = _h
		self.type = _t
		self.placement_rule = _p
		self.metadata = _m

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
		
	for x in range(-1, 2):
		for z in range(-1, 2):
			var target = coord + Vector2i(x, z)
			if data.has(target):
				return data[target].height
	return 0.0
