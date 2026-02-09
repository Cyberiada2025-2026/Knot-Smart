class_name TreeGenerator
extends Node3D

var tree_skeleton: TreeSkeleton
var tree_mesh: TreeMesh
@export var tree_parameters: TreeParameters

var is_branch = false

# wowee this code is so shitty change it asap
func _ready() -> void:	
	var skeleton = tree_skeleton.generate_skeleton(tree_parameters)
	
	for branch in skeleton:
		add_child(generate_tree(branch))
		tree_mesh.reset()

func generate_tree(branch: Array) -> MeshInstance3D:
	
	var array_mesh = tree_mesh.generate_mesh(branch, tree_parameters, is_branch)
	var mesh = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	var texture = load("res://shared/tree_generator/kora.png")
	material.uv1_triplanar = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color *= 0.55
	array_mesh.surface_set_material(0, material)
	mesh.mesh = array_mesh
	
	is_branch = true
	
	return mesh
