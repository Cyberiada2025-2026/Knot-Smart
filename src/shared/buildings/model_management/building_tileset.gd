@tool
class_name BuildingTileset
extends Resource

@export var enterable_tileset: MeshLibrary
@export var unenterable_tileset: MeshLibrary
@export var grid_size: Vector3 = Vector3.ONE


func get_tileset(is_enterable: bool) -> MeshLibrary:
	return enterable_tileset if is_enterable else unenterable_tileset
