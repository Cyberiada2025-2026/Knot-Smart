class_name MapTileData
extends Resource

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
	print(self.name, ": Created blueprint of size ", world_size)


func get_height(coord: Vector2i) -> float:
	for x in 2:
		for z in 2:
			var target = coord - Vector2i(x, z)
			if data.has(target):
				return data[target].height
	return 0.0
