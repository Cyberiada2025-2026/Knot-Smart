class_name TreeMeshGenerator
extends Node

var tree_generator: TreeGenerator

func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_mesh_generator = self
	

func generate_skin(branch: TreeBranch) -> ArrayMesh:
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	add_stripes(vertices, branch, branch.sides)
	add_indices(indices, len(branch.pos_array)-1, branch.sides)

	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	
	return arr_mesh


func add_stripes(vertices: PackedVector3Array, branch: TreeBranch, sides: int):
	var r = branch.r
	for center in branch.pos_array:
		var angle: float = 2*PI / sides
		for i in range(sides, 0, -1):
			var vertex = Vector3(cos(i*angle)*r, 0.0, sin(i*angle)*r)
			vertex += center
			vertices.push_back(vertex)
		r *= branch.r_low


func add_indices(indices: PackedInt32Array, levels: int, length: int):
	for i in range(levels):
		for j in range(length):
			indices.push_back(i*length+j)
			indices.push_back((i+1)*length+j)
			
		indices.push_back(i*length)
		indices.push_back((i+1)*length)
