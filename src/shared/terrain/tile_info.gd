class_name TileInfo
extends Resource

enum PlacementRule {
	FLAT,
	SLOPE_X,
	SLOPE_Z,
	BLOCKED,
}

var height: float
var object: MeshInstance3D
var appears_many_times: bool
var placement_rule: PlacementRule

func _init(
	_height: float = 0.0,
	_placement_rule: PlacementRule = PlacementRule.FLAT,
	_object: MeshInstance3D =  null,
	_appears_many_times: bool = false
):
	self.height = _height
	self.placement_rule = _placement_rule
	self.object = _object
	self.appears_many_times = _appears_many_times
