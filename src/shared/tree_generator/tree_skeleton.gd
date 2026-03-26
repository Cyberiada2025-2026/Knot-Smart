@tool
class_name TreeSkeleton
extends Node


const FULL_ANGLE: float = 2*PI

var tree_generator: TreeGenerator
var params: TreeParameters
var branch_count: int
var branches: Array[TreeBranch] = []
var rec_level: int = 0


func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_skeleton = self


func generate_skeleton(parent_branches: Array[TreeBranch] = []) -> Array[TreeBranch]:
	branches = []
	# trunk
	if rec_level == 0:
		var trunk = TreeBranch.new()
		trunk.pos_array = skeleton_branch(params.h, params.levels)
		set_branch(trunk, params.r, params.r_low, params.sides)
		branches.push_back(trunk)
	else:
		branch_count = randi()%(params.max_count-params.min_count+1)+params.min_count
		rec_branches(parent_branches)
	rec_level+=1
	return branches

# make recursive levels of branches
func rec_branches(parent_branches: Array[TreeBranch]):
	for parent_branch in parent_branches:
		for i in range(branch_count):
			var branch = TreeBranch.new()
			var idx: int # where on the branch is located child branch
			if rec_level>1:
				idx = randi() % len(parent_branch.pos_array)
				branch.transform = calculate_rotation(parent_branch.transform)
			else: # first level of branches coming from trunk
				var angle: float = FULL_ANGLE / branch_count
				idx = parent_branch.pos_array.size()-1
				branch.transform = calculate_rotation(parent_branch.transform)
				#branch_transform = calculate_rotation(Vector3(sin(i*angle), 0.0, cos(i*angle)), true)
			var origin = parent_branch.transform.translated_local(parent_branch.pos_array[idx]).origin
			branch.transform.origin = origin
			branch.pos_array = skeleton_branch(params.h_branch, params.levels_branch)
			if rec_level>1:
				set_branch(branch, get_new_r(parent_branch), parent_branch.r_low, parent_branch.sides)
			else:
				set_branch(branch, params.r_branch, params.r_low, params.sides)
			branches.push_back(branch)


func skeleton_branch(h: float, levels: int) -> PackedVector3Array:
	var branch_pos = PackedVector3Array()
	var last = Vector3.ZERO
	branch_pos.push_back(last)
	for i in range(levels):
		var new = last + Vector3(
			randf()*params.diff-params.diff/2,
			randf()*params.diff-params.diff/2+h,
			randf()*params.diff-params.diff/2)
		branch_pos.push_back(new)
		last = new
	return branch_pos


func set_branch(branch:TreeBranch, r: float, r_low: float, sides: int):
	branch.r = r
	branch.r_low = r_low
	branch.sides = sides


func calculate_rotation(base: Transform3D, is_first_level = false) -> Transform3D:
	var rot_matrix = Transform3D()
	var angle = randf()*PI
	if params.subtype == "SIDE":
		return rot_matrix.rotated(Vector3.RIGHT, PI/3)
	if is_first_level:
		return base
	if randf()>0.5:
		rot_matrix = base.rotated(Vector3.BACK, angle)
	else:
		rot_matrix = rot_matrix.rotated(Vector3.FORWARD, angle)
	if randf()>0.5:
		rot_matrix = rot_matrix.rotated(Vector3.RIGHT, angle)
	else:
		rot_matrix = rot_matrix.rotated(Vector3.LEFT, angle)
	rot_matrix = rot_matrix.rotated(Vector3.UP, angle)
	return rot_matrix

# shrink base radius of branches from the next level
func get_new_r(branch: TreeBranch) -> float:
	return branch.r*pow(branch.r_low, 2)
