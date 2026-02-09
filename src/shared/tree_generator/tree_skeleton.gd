class_name TreeSkeleton
extends Node

var tree_generator: TreeGenerator
var box: Vector3
var params: TreeParameters

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_skeleton = self
	

func generate_skeleton(parameters: TreeParameters) -> Array:
	var points_arrays: Array = []
	box = box
	params = parameters
	var trunk = skeleton_branch(Vector3.ZERO)
	points_arrays.push_back(trunk)
	for i in range(3):
		print(trunk[trunk.size()-1])
		points_arrays.push_back(skeleton_branch(trunk[trunk.size()-1]*0.95))
	return points_arrays

func skeleton_branch(offset: Vector3) -> Array:
	var branch = []
	var last = offset
	branch.push_back(last)
	for i in range(params.levels):		
		var new = last + Vector3(
			add_rand(params.diff),
			add_rand(params.diff)+params.h,
			add_rand(params.diff))
		last = new
		branch.push_back(new)
	return branch

func add_rand(param) -> float:
	return randf()*param-param/2
