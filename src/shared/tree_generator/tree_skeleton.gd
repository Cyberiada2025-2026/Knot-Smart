class_name TreeSkeleton
extends Node

var tree_generator: TreeGenerator
var box: Vector3
var params: TreeParameters


func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_skeleton = self
	


func generate_skeleton(parameters: TreeParameters) -> Array:
	
	var points_arrays: Array = []
	params = parameters
	var trunk = skeleton_branch(Vector3.ZERO, Vector3.ZERO, params.h, params.levels)
	points_arrays.push_back(trunk)
	var branch_count = randi()%(params.max_count-1)+2 # random [2, max_count]
	var angle: float = 2*PI / branch_count
	for i in range(branch_count):
		points_arrays.push_back(skeleton_branch(trunk[trunk.size()-1]*0.95, Vector3(cos(i*angle), 0.0, sin(i*angle)), params.h_branch, params.levels_branch))
	return points_arrays

func skeleton_branch(offset: Vector3, rotation: Vector3, h: float, levels: int) -> Array:
	var branch = []
	var last = offset
	branch.push_back(last)
	for i in range(levels):		
		var new = last + Vector3(
			add_rand(params.diff),
			add_rand(params.diff)+h,
			add_rand(params.diff)) + rotation
		last = new
		branch.push_back(new)
	return branch

func add_rand(param) -> float:
	return randf()*param-param/2
