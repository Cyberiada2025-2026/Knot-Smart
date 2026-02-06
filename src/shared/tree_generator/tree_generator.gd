class_name TreeGenerator
extends Node3D

var tree_skeleton: TreeSkeleton
var tree_mesh: TreeMesh
@export var tree_parameters: TreeParameters

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	add_child(generate_tree())

func generate_tree() -> MeshInstance3D:
	var skeleton = tree_skeleton.generate_skeleton(tree_parameters)
	var array_mesh = tree_mesh.generate_mesh(skeleton, tree_parameters)
	var mesh = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	var texture = load("res://shared/tree_generator/kora.png")
	material.uv1_triplanar = true
	material.albedo_texture = texture
	array_mesh.surface_set_material(0, material)
	mesh.mesh = array_mesh
	
	return mesh
