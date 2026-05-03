@tool
class_name FoliageGenerator
extends Node3D

const DIR_PATH = "user://foliage"

@export_tool_button("Generate", "Callable") var generate_button = on_generate
@export var params: FoliageParameters

var foliage: Node3D
var foliage_scene: PackedScene
var standalone: bool = true


func _init() -> void:
	standalone = false


func _ready() -> void:
	on_generate()


func generate_foliage():
	foliage = Node3D.new()
	foliage.name = "foliage"
	var angle = PI/params.count
	var new_scale = params.scale + (randf() - 0.5) * params.scale_randomization
	for i in range(params.count):
		var mesh = MeshInstance3D.new()
		mesh.mesh = PlaneMesh.new()
		mesh.scale = params.plane_scale * new_scale
		mesh.position = params.plane_offset * new_scale
		mesh.position.y += params.plane_scale.y * new_scale
		mesh.rotate_z(angle*i)
		mesh.rotate_x(PI/2)
		mesh.mesh.surface_set_material(0, params.material)
		foliage.add_child(mesh)
		mesh.owner = foliage
	add_child(foliage)

	if standalone:
		serialize()


func on_generate():
	foliage_scene = PackedScene.new()
	for child in get_children():
		child.queue_free()
	generate_foliage()


func serialize():
	add_child(Serialize.serialize(foliage_scene, foliage, DIR_PATH))
