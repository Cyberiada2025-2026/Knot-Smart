@tool
class_name FoliageGenerator
extends Node3D

const DIR_PATH = "user://foliage"

@export_tool_button("Generate", "Callable") var generate_button = on_generate
@export var params: FoliageParameters

var foliage: StaticBody3D
var foliage_scene: PackedScene
var standalone: bool = true


func _ready() -> void:
	if standalone:
		on_generate()


func generate_foliage():
	foliage = StaticBody3D.new()
	foliage.name = "foliage"
	var angle = PI/params.count
	for i in range(params.count):
		var mesh = MeshInstance3D.new()
		mesh.mesh = PlaneMesh.new()
		mesh.scale = params.plane_scale
		mesh.position = params.plane_offset
		mesh.position.y += params.plane_scale.y
		mesh.rotate_z(angle*i)
		mesh.rotate_x(PI/2)
		mesh.mesh.surface_set_material(0, params.material)
		foliage.add_child(mesh)
		mesh.owner = foliage
	
	if standalone:
		serialize()


func on_generate():
	foliage_scene = PackedScene.new()
	for child in get_children():
		if child is StaticBody3D:
			child.queue_free()
	generate_foliage()


func serialize():
	add_child(Serialize.serialize(foliage_scene, foliage, DIR_PATH))
