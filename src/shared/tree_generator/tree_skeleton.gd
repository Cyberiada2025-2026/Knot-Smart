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
	points_arrays.push_back(skeleton_trunk())
	return points_arrays

func skeleton_trunk() -> Array:
	var trunk = []
	var last = Vector3.ZERO
	trunk.push_back(last)
	for i in range(params.levels):		
		var new = last + Vector3(
			add_rand(params.diff),
			add_rand(params.diff)+params.h,
			add_rand(params.diff))
		last = new
		trunk.push_back(new)
	return trunk
	
func skeleton_branch():
	pass

func add_rand(param) -> float:
	return randf()*param-param/2
