class_name TreeMesh
extends Node

var tree_generator: TreeGenerator


func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_mesh = self
	

func generate_skin(skeleton: Array, param: TreeParameters, is_branch: bool) -> ArrayMesh:
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	var r = param.r
	var r_low = param.r_low
	var sides = param.sides
	if is_branch:
		r = param.r_branch
		r_low = param.r_low_branch
		sides = param.sides_branch
	
	for node in skeleton:
		add_stripe(vertices, node, r, sides)
		r = r * param.r_low
		
	add_indices(indices, len(skeleton)-1, sides)

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	
	return arr_mesh


func add_stripe(vertices: PackedVector3Array, center: Vector3, r: float, sides: int):
	var angle: float = 2*PI / sides
	for i in range(sides, 0, -1):
		var vertex = Vector3(cos(i*angle)*r+center.x, center.y, sin(i*angle)*r+center.z)
		vertices.push_back(vertex)

func add_indices(indices: PackedInt32Array, levels: int, length: int):
	for i in range(levels):
		for j in range(length):
			indices.push_back(i*length+j)
			indices.push_back((i+1)*length+j)
			
		indices.push_back(i*length)
		indices.push_back((i+1)*length)
