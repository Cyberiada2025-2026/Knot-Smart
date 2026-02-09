class_name TreeGenerator
extends Node3D

var tree_skeleton: TreeSkeleton
var tree_mesh: TreeMesh
@export var tree_type: TreeType
@export var tree_placement: PackedVector3Array

var tree_parameters: TreeParameters

# tree parameters type
enum TreeType {
	DEFAULT,
	CURSED
}

# wowee this code is so shitty change it asap
func _ready() -> void:	
	tree_parameters = get_params(tree_type)
	for i in range(15):
		for j in range(25):
			if randf() < 0.6:
				tree_placement.push_back(Vector3(i*8.0+tree_skeleton.add_rand(4.0), 0.0, j*6.0+tree_skeleton.add_rand(4.0)))
	
	for pos in tree_placement:
		generate_tree(pos)


func generate_tree(pos: Vector3):
	var is_branch = false
	var tree = Node3D.new()
	add_child(tree)
	tree.global_rotate(Vector3(0.0,1.0,0.0), PI*randf())
	tree.global_translate(pos)
	
	var skeleton = tree_skeleton.generate_skeleton(tree_parameters)
	for branch in skeleton:
		tree.add_child(generate_mesh(branch, is_branch))
		is_branch = true


func generate_mesh(branch: Array, is_branch: bool) -> MeshInstance3D:
	var array_mesh = tree_mesh.generate_skin(branch, tree_parameters, is_branch)
	var mesh = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	var texture = load(tree_parameters.tex_path)
	material.uv1_triplanar = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color *= 0.55
	array_mesh.surface_set_material(0, material)
	mesh.mesh = array_mesh
	
	return mesh
	

func get_params(type: int) -> TreeParameters:
	var params = TreeParameters.new()
	match(type):
		TreeType.CURSED:
			params.levels = 3
			params.r_low = 0.75
			params.min_count = 2
			params.max_count = 2
			params.levels_branch = 7
			return params
	return params
