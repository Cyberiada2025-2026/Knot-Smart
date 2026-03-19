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


func generate_skeleton(tree_params: TreeParameters) -> Array:
	branches = []
	params = tree_params
	# trunk
	var trunk = skeleton_branch(Vector3.ZERO, Vector3.ZERO, params.h, params.levels)
	set_branch(trunk, params.r, params.r_low, params.sides)
	branches.push_back(trunk)
	branch_count = randi()%(params.max_count-params.min_count+1)+params.min_count
	# branches first level
	rec_branches(trunk, params.levels_branch)
	return branches

# make recursive levels of branches
func rec_branches(curr_branch: TreeBranch, levels_branch: int, rec_level = 1, rot = Vector3.ZERO):
	if params.rec_level<rec_level:
		return
	var branch = curr_branch.pos_array
	for i in range(branch_count):
		var idx: int # where on the branch is located child branch
		var new_rotation: Vector3
		if rec_level>1:
			idx = randi() % len(branch)
			new_rotation = calculate_rotation(rot)
		else: # first level of branches coming from trunk
			var angle: float = 2*PI / branch_count
			idx = branch.size()-1
			new_rotation = calculate_rotation(Vector3(sin(i*angle), 0.0, cos(i*angle)), true)
		var new_branch = skeleton_branch(branch[idx], new_rotation, params.h_branch, levels_branch)
		if rec_level>1:
			set_branch(new_branch, get_new_r(curr_branch), curr_branch.r_low, curr_branch.sides)
		else:
			set_branch(new_branch, params.r_branch, params.r_low, params.sides)
		branches.push_back(new_branch)
		var new_levels_branch = randi()%levels_branch+1
		rec_branches(new_branch, new_levels_branch, rec_level+1, new_rotation)


func skeleton_branch(offset: Vector3, rot: Vector3, h: float, levels: int) -> TreeBranch:
	var branch_pos = []
	var last = offset
	branch_pos.push_back(last)
	for i in range(levels):
		var new = last + Vector3(
			randf()*params.diff-params.diff/2,
			randf()*params.diff-params.diff/2+h,
			randf()*params.diff-params.diff/2)
		if rot.is_normalized():
			new = new.rotated(rot, params.angle)
		else:
			new += rot
		branch_pos.push_back(new)
		last = new
	var branch = TreeBranch.new()
	branch.pos_array = branch_pos
	return branch


func set_branch(branch:TreeBranch, r: float, r_low: float, sides: int):
	branch.r = r
	branch.r_low = r_low
	branch.sides = sides


func calculate_rotation(base: Vector3, is_first_level = false) -> Vector3:
	if params.subtype == "SIDE":
		return Vector3.RIGHT
	if is_first_level:
		return base
	# vibes based math (trying to rotate branch against its parent branch)
	var angle = randf()*PI
	var rot = base.rotated(Vector3.BACK, angle)
	rot = rot.rotated(Vector3.RIGHT, angle)
	rot = rot.rotated(Vector3.UP, angle)
	return rot

# shrink base radius of branches from the next level
func get_new_r(branch: TreeBranch) -> float:
	return branch.r*pow(branch.r_low, 2)
