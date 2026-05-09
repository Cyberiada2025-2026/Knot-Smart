@tool
class_name TreeSkeleton
extends Node

var tree_generator: TreeGenerator
var params: TreeParameters
var branch_count: int
var branches: Array[TreeBranch] = []
var rec_level: int = 0


func generate_skeleton(parent_branches: Array[TreeBranch] = []) -> Array[TreeBranch]:
	branches = []
	if rec_level == 0:
		var trunk = TreeBranch.new()
		trunk.pos_array = branch_skeleton(params.trunk_segment_length, params.trunk_segment_count)
		set_branch(trunk, params.trunk_radius, params.trunk_rate_of_shrinking, params.trunk_sides)
		branches.push_back(trunk)
	else:
		branches_next_level(parent_branches)
	rec_level += 1
	set_new_branch_count()
	return branches


func branches_next_level(parent_branches: Array[TreeBranch]):
	for parent_branch in parent_branches:
		for i in range(branch_count):
			var branch = TreeBranch.new()
			var idx: int  # where on the parent branch is located child branch
			if rec_level > 1:
				idx = randi() % (len(parent_branch.pos_array) - 1)
				branch.transform = calculate_rotation(parent_branch.transform, get_angle())
			else:  # first level of branches coming from trunk
				var angle: float = TAU / branch_count
				idx = parent_branch.pos_array.size() - 1
				branch.transform = calculate_rotation(parent_branch.transform, angle * i)
			var translated = parent_branch.transform.translated_local(parent_branch.pos_array[idx])
			branch.transform.origin = translated.origin
			branch.pos_array = branch_skeleton(
				params.branch_segment_length, params.branch_segment_count
			)
			set_branch(
				branch,
				get_radius(parent_branch),
				params.branch_rate_of_shrinking,
				params.branch_sides
			)
			branches.push_back(branch)


func branch_skeleton(h: float, stripes: int) -> PackedVector3Array:
	var branch_pos = PackedVector3Array()
	var last = Vector3.ZERO
	branch_pos.push_back(last)
	for i in range(stripes):
		var new = (
			last
			+ Vector3(
				get_random_segment_displacement(),
				get_random_segment_displacement() + h,
				get_random_segment_displacement()
			)
		)
		branch_pos.push_back(new)
		last = new
	return branch_pos


func set_branch(branch: TreeBranch, radius: float, rate_of_shrinking: float, sides: int):
	branch.radius = radius
	branch.rate_of_shrinking = rate_of_shrinking
	branch.sides = sides


func calculate_rotation(base: Transform3D, angle: float) -> Transform3D:
	var rot_matrix = Transform3D()
	if params.subtype == "SIDE":
		return rot_matrix.rotated(Vector3.RIGHT, params.branch_spread_angle)
	if rec_level == 1:
		rot_matrix = base.rotated(Vector3(1.0, 0.0, 1.0).normalized(), params.branch_spread_angle)
		rot_matrix = rot_matrix.rotated(Vector3.UP, angle)
		return rot_matrix
	var direction = Vector3.BACK if randf() > 0.5 else Vector3.FORWARD
	rot_matrix = base.rotated(direction, angle)
	direction = Vector3.RIGHT if randf() > 0.5 else Vector3.LEFT
	rot_matrix = rot_matrix.rotated(direction, angle)
	rot_matrix = rot_matrix.rotated(Vector3.UP, angle)
	return rot_matrix


func get_radius(branch: TreeBranch):
	var base_radius = params.branch_radius if rec_level == 1 else branch.radius
	return base_radius * pow(params.branch_rate_of_shrinking, rec_level - 1)


func set_new_branch_count():
	branch_count = randi_range(params.min_count, params.max_count)


func get_angle() -> float:
	return randf() * TAU


func get_random_segment_displacement():
	return (randf() - 0.5) * params.segment_displacement
