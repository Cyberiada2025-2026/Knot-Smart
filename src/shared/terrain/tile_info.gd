extends Resource
class_name TileInfo

enum TileType {EMPTY, ROAD}
enum PlacementRule { 
	FLAT,  
	SLOPE_X, 
	SLOPE_Z, 
	BLOCKED,
}

var height: float
var type: TileType
var placement_rule: PlacementRule

func _init(_h: float = 0.0, _t: TileType = TileType.EMPTY, _p: PlacementRule = PlacementRule.FLAT):
	self.height = _h
	self.type = _t
	self.placement_rule = _p
