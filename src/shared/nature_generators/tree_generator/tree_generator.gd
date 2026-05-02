@tool
class_name TreeGenerator
extends Node3D

const DIR_PATH = "user://trees"
const BRANCH_SPAWN_PERCENTAGE = 0.6

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
	for i in range(params.branch_recursion_level + 1):  # levels of branches + trunk
		branches_one_level = tree_skeleton.generate_skeleton(branches_one_level)
		for branch in branches_one_level:
			generate_mesh(branch, params.material)
	if params.flat_branches_parameters != null:
		branches_one_level = tree_skeleton.generate_skeleton(branches_one_level)
		for branch in branches_one_level:
			if randf()<BRANCH_SPAWN_PERCENTAGE:
				add_flat_branches(branch)
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


func add_flat_branches(branch: TreeBranch):
	var foliage_generator = FoliageGenerator.new()
	foliage_generator.standalone = false
	foliage_generator.params = params.flat_branches_parameters
	foliage_generator.generate_foliage()
	foliage_generator.transform = branch.transform
	tree.add_child(foliage_generator)
	foliage_generator.owner = tree
	for child in foliage_generator.get_children(true):
		child.owner = tree


func on_generate():
	tree_scene = PackedScene.new()
	tree_skeleton.rec_level = 0
	for child in get_children():
		if child is StaticBody3D:
			child.queue_free()
	generate_tree()


func serialize():
	var result = tree_scene.pack(tree)
	if result == OK:
		if not DirAccess.dir_exists_absolute(DIR_PATH):
			DirAccess.make_dir_absolute(DIR_PATH)
		var error = ResourceSaver.save(
			tree_scene, DIR_PATH + "/tree%d.tscn" % tree.get_rid().get_id()
		)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
		add_child(tree_scene.instantiate())
