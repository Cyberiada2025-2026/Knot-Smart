class_name TreeSkeleton
extends Node

var tree_generator: TreeGenerator
var box: Vector3
var params: TreeParameters

var branch_count: int

func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_skeleton = self
	

func generate_skeleton(parameters: TreeParameters) -> Array:
	var points_arrays: Array = []
	params = parameters
	var trunk = skeleton_branch(Vector3.ZERO, Vector3.ZERO, params.h, params.levels)
	points_arrays.push_back(trunk)
	branch_count = randi()%(params.max_count-1)+2 # random [2, max_count]
	var angle: float = 2*PI / branch_count
	for i in range(branch_count):
		var branch = skeleton_branch(trunk[trunk.size()-1]*0.95, Vector3(cos(i*angle), 0.0, sin(i*angle)), params.h_branch, params.levels_branch)
		points_arrays.push_back(branch)
		rec_branches(points_arrays, branch, 1, Vector3(cos(i*angle), 0.0, sin(i*angle)), params.levels_branch)
	return points_arrays


func rec_branches(points: Array, curr_branch: Array, rec_level: int, rotation: Vector3, levels_branch: int):
	if params.rec_level<=rec_level:
		return
	for i in range(randi()%branch_count+1):
		var idx = randi() % len(curr_branch)
		var angle = randf()*PI+1.0
		
		var rot = Transform3D()
		rot.basis = Basis(Vector3(cos(angle), -sin(angle), 0.0), Vector3(sin(angle), cos(angle), 0.0), Vector3.BACK)
		#rot.origin = curr_branch[idx]
		var rot2 = Transform3D()
		rot2.basis = Basis(Vector3.RIGHT, Vector3(0.0, cos(angle), -sin(angle)), Vector3(0.0, sin(angle), cos(angle)))
		var rot3 = Transform3D()
		rot3.basis = Basis(Vector3(cos(angle), 0.0, sin(angle)), Vector3.UP, Vector3(-sin(angle), 0.0, cos(angle)))
		var new_rotation = (rot*rotation.normalized()).normalized()
		new_rotation = (rot2*new_rotation).normalized()
		new_rotation = (rot3*new_rotation).normalized()
		print(new_rotation)
		
		var branch = skeleton_branch(curr_branch[idx], new_rotation, params.h, levels_branch)
		points.push_back(branch)
		rec_branches(points, branch, rec_level+1, new_rotation, clampi(levels_branch-(params.levels_branch/params.rec_level+1), 1, levels_branch))


func skeleton_branch(offset: Vector3, rotation: Vector3, h: float, levels: int) -> Array:
	var branch = []
	var last = offset
	var angle = -PI/30
	var ax = last.cross(rotation).normalized()
	branch.push_back(last)
	for i in range(levels):		
		var new = last + Vector3(
			add_rand(params.diff),
			add_rand(params.diff)+h,
			add_rand(params.diff))
			
		last = new.rotated(ax, angle)
		branch.push_back(last)
		
	return branch


func add_rand(param) -> float:
	return randf()*param-param/2
