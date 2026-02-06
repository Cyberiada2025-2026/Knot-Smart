class_name TreeMesh
extends Node

var tree_generator: TreeGenerator
var vertices = PackedVector3Array()
var indices = PackedInt32Array()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# mesh = generate_mesh()
	pass

func _enter_tree() -> void:
	tree_generator = get_parent()
	tree_generator.tree_mesh = self
	

func generate_mesh(skeleton: Array, param: TreeParameters) -> ArrayMesh:
	var r = param.r
	var trunk = skeleton[0]
	
	for node in trunk:
		add_stripe(node, r)
		r = r * param.r_low
		print(r)
		
	add_indices(len(trunk)-1, stripe_sides())

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	
	return arr_mesh

func stripe_sides() -> int:
	return 6

func add_stripe(center: Vector3, r: float):
	var h = center.z
	var sides = stripe_sides()
	var angle: float = 2*PI / sides
	for i in range(sides):
		vertices.push_back(Vector3(cos(i*angle)*r+center.x, center.y, sin(i*angle)*r+center.z))		

func add_indices(levels: int, length: int):
	for i in range(levels):
		for j in range(length):
			indices.push_back((i+1)*length+j)
			indices.push_back(i*length+j)
		indices.push_back((i+1)*length)
		indices.push_back(i*length)
