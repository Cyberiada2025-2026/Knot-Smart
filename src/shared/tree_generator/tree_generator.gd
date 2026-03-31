@tool
class_name TreeGenerator
extends Node3D


const TEX_DARKEN = 0.5

@export_tool_button("Generate", "Callable") var generate_button = on_generate
@export var params: TreeParameters

var tree_skeleton: TreeSkeleton
var tree_mesh_generator: TreeMeshGenerator
var tree: StaticBody3D


func _ready() -> void:
	tree_skeleton = TreeSkeleton.new()
	tree_skeleton.tree_generator = self
	tree_mesh_generator = TreeMeshGenerator.new()
	tree_mesh_generator.tree_generator = self
	on_generate()


func generate_tree():
	tree = StaticBody3D.new()
	add_child(tree)
	tree_skeleton.params = params
	var branches_one_level: Array[TreeBranch] = []
	for i in range(params.branch_recursion_level+1): # levels of branches + trunk
		branches_one_level = tree_skeleton.generate_skeleton(branches_one_level)
		for branch in branches_one_level:
			generate_mesh(branch, params.material)


func generate_mesh(branch: TreeBranch, material: StandardMaterial3D):
	var mesh = MeshInstance3D.new()
	var array_mesh = tree_mesh_generator.generate_array_mesh(branch)
	#material.uv1_triplanar = true
	#material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#material.albedo_texture = texture
	#material.albedo_color *= TEX_DARKEN
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
	if Engine.is_editor_hint():
		tree.owner = get_tree().edited_scene_root
		mesh.owner = get_tree().edited_scene_root
		collision.owner = get_tree().edited_scene_root


func on_generate():
	tree_skeleton.rec_level = 0
	for child in get_children():
		if child is StaticBody3D:
			child.queue_free()
	generate_tree()
