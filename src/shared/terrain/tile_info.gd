class_name TileInfo
extends Resource

enum TileType { EMPTY, ROAD }
enum PlacementRule {
	FLAT,
	SLOPE_X,
	SLOPE_Z,
	BLOCKED,
}

var height: float
var type: TileType
var placement_rule: PlacementRule


func _init(
	_height: float = 0.0,
	_type: TileType = TileType.EMPTY,
	_placement_rule: PlacementRule = PlacementRule.FLAT
):
	self.height = _height
	self.type = _type
	self.placement_rule = _placement_rule
