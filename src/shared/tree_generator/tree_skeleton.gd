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
	if rec_level == 0:
		var trunk = TreeBranch.new()
		trunk.pos_array = branch_skeleton(params.h, params.stripes)
		set_branch(trunk, params.r, params.r_low, params.sides)
		branches.push_back(trunk)
	else:
		branches_next_level(parent_branches)
	rec_level+=1
	set_new_branch_count()
	return branches


func branches_next_level(parent_branches: Array[TreeBranch]):
	for parent_branch in parent_branches:
		for i in range(branch_count):
			var branch = TreeBranch.new()
			var idx: int # where on the parent branch is located child branch
			if rec_level>1:
				idx = randi() % (len(parent_branch.pos_array)-1)
				branch.transform = calculate_rotation(parent_branch.transform, get_angle())
			else: # first level of branches coming from trunk
				var angle: float = FULL_ANGLE / branch_count
				idx = parent_branch.pos_array.size()-1
				branch.transform = calculate_rotation(parent_branch.transform, angle*i)
			var translated = parent_branch.transform.translated_local(parent_branch.pos_array[idx])
			branch.transform.origin = translated.origin
			branch.pos_array = branch_skeleton(params.h_branch, params.stripes_branch)
			if rec_level>1:
				set_branch(branch, get_new_r(parent_branch),
					parent_branch.r_low, parent_branch.sides)
			else:
				set_branch(branch, params.r_branch, params.r_low_branch, params.sides)
			branches.push_back(branch)


func branch_skeleton(h: float, stripes: int) -> PackedVector3Array:
	var branch_pos = PackedVector3Array()
	var last = Vector3.ZERO
	branch_pos.push_back(last)
	for i in range(stripes):
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


func calculate_rotation(base: Transform3D, angle: float) -> Transform3D:
	var rot_matrix = Transform3D()
	if params.subtype == "SIDE":
		return rot_matrix.rotated(Vector3.RIGHT, params.angle)
	if rec_level==1:
		rot_matrix = base.rotated(Vector3(1.0,0.0,1.0).normalized(),params.angle)
		rot_matrix = rot_matrix.rotated(Vector3.UP, angle)
		return rot_matrix
	var direction = Vector3.BACK if randf() > 0.5 else Vector3.FORWARD
	rot_matrix = base.rotated(direction, angle)
	direction = Vector3.RIGHT if randf() > 0.5 else Vector3.LEFT
	rot_matrix = rot_matrix.rotated(direction, angle)
	rot_matrix = rot_matrix.rotated(Vector3.UP, angle)
	return rot_matrix

## shrink base radius of branches from the next level
func get_new_r(branch: TreeBranch) -> float:
	return branch.r*pow(branch.r_low, 2)


func set_new_branch_count():
	branch_count = randi_range(params.min_count, params.max_count)


func get_angle() -> float:
	return randf()*FULL_ANGLE
