@tool
class_name TreeGenerator
extends Node3D

const DIR_PATH = "user://trees"

@export_tool_button("Generate", "Callable") var generate_button = on_generate
@export var params: TreeParameters

var tree_skeleton: TreeSkeleton
var tree_mesh_generator: TreeMeshGenerator
var tree: StaticBody3D
var tree_scene: PackedScene


func _ready() -> void:
	tree_skeleton = TreeSkeleton.new()
	tree_skeleton.tree_generator = self
	tree_mesh_generator = TreeMeshGenerator.new()
	tree_mesh_generator.tree_generator = self
	on_generate()


func generate_tree():
	tree = StaticBody3D.new()
	tree.name = "tree"
	tree_skeleton.params = params
	var branches_one_level: Array[TreeBranch] = []
	for i in range(params.branch_recursion_level+1):
		branches_one_level = tree_skeleton.generate_skeleton(branches_one_level)
		for branch in branches_one_level:
			generate_mesh(branch, params.material)
	if params.flat_branches_material != null:
		branches_one_level = tree_skeleton.generate_skeleton(branches_one_level)
		for branch in branches_one_level:
			var foliage_generator = FoliageGenerator.new()
			foliage_generator.standalone = false
			foliage_generator.params = FoliageParameters.new()
			foliage_generator.params.material = params.flat_branches_material
			foliage_generator.generate_foliage()
			var foliage = foliage_generator.foliage
			foliage.transform = branch.transform
			tree.add_child(foliage)
			foliage.owner = tree
			for child in foliage.get_children():
				child.owner = tree
	serialize()


func generate_mesh(branch: TreeBranch, material: StandardMaterial3D):
	var mesh = MeshInstance3D.new()
	var array_mesh = tree_mesh_generator.generate_array_mesh(branch)
	array_mesh.surface_set_material(0, material)
	mesh.mesh = array_mesh
	mesh.transform = branch.transform
	tree.add_child(mesh)
	var collision = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(array_mesh.get_faces())
	collision.shape = shape
	collision.transform = branch.transform
	tree.add_child(collision)
	mesh.owner = tree
	collision.owner = tree


func on_generate():
	tree_scene = PackedScene.new()
	tree_skeleton.rec_level = 0
	for child in get_children():
		if child is StaticBody3D:
			child.queue_free()
	generate_tree()


func serialize():
	add_child(Serialize.serialize(tree_scene, tree, DIR_PATH))
