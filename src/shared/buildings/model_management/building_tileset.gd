@tool
class_name BuildingTileset
extends Resource

@export var mesh_library: MeshLibrary
@export var grid_size: Vector3i = Vector3i.ONE
## Mesh Libraries made for eneterable buildings should have their own collision setup.
@export var is_enterable: bool = true
