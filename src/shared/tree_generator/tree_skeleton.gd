@tool
class_name TreeSkeleton
extends Node


var tree_generator: TreeGenerator
var params: TreeParameters
var branch_count: int
var branches: Array[TreeBranch] = []


func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_skeleton = self


func generate_skeleton(parameters: TreeParameters) -> Array:
	branches = []
	params = parameters
	# trunk
	var trunk = skeleton_branch(Vector3.ZERO, Vector3.ZERO, params.h, params.levels)
	set_branch(trunk, params.r, params.r_low, params.sides)
	branches.push_back(trunk)
	branch_count = randi()%(params.max_count-params.min_count+1)+params.min_count
	var angle: float = 2*PI / branch_count # line branches growing from trunk in a circle
	# branches first level
	for i in range(branch_count):
		var rotation = Vector3(cos(i*angle), 0.0, sin(i*angle))
		var branch = skeleton_branch(trunk.pos_array[trunk.pos_array.size()-1]*0.95,
			rotation, params.h_branch, params.levels_branch)
		set_branch(branch, params.r_branch, params.r_low_branch, params.sides_branch)
		branches.push_back(branch)
		# branches next levels
		rec_branches(branch, 2, rotation, params.levels_branch)
	return branches


func rec_branches(curr_branch: TreeBranch, rec_level: int, rotation: Vector3, levels_branch: int):
	if params.rec_level<rec_level:
		return
	var branch = curr_branch.pos_array
	for i in range(randi()%branch_count+1):
		var idx = randi() % len(branch)
		var angle = randf()*PI
		# vibes based math (trying to rotate branch against its parent branch)
		var new_rotation = rotation.rotated(Vector3.BACK, angle)
		new_rotation = new_rotation.rotated(Vector3.RIGHT, angle)
		new_rotation = new_rotation.rotated(Vector3.UP, angle)
		var new_branch = skeleton_branch(branch[idx], new_rotation, params.h, levels_branch)
		set_branch(new_branch, curr_branch.r*pow(curr_branch.r_low,2),
			curr_branch.r_low, curr_branch.sides)
		branches.push_back(new_branch)
		var new_levels_branch = randi()%levels_branch+1
		rec_branches(new_branch, rec_level+1, new_rotation, new_levels_branch)


func skeleton_branch(offset: Vector3, rotation: Vector3, h: float, levels: int) -> TreeBranch:
	var branch_pos = []
	var last = offset
	branch_pos.push_back(last)
	for i in range(levels):
		var new = last + Vector3(
			randf()*params.diff-params.diff/2,
			randf()*params.diff-params.diff/2+h,
			randf()*params.diff-params.diff/2)
		# vibes based math cd
		if rotation.is_normalized():
			new = new.rotated(rotation, params.angle)
		else:
			new+=rotation
		branch_pos.push_back(new)
		last = new
	var branch = TreeBranch.new()
	branch.pos_array = branch_pos
	return branch


func set_branch(branch:TreeBranch, r: float, r_low: float, sides: int):
	branch.r = r
	branch.r_low = r_low
	branch.sides = sides
