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
	on_generate()


func generate_tree():
	tree = StaticBody3D.new()
	add_child(tree)
	#	skeleton - blueprint for mesh
	#var skeleton = tree_skeleton.generate_skeleton(params)
	tree_skeleton.params = params
	var level_branches: Array[TreeBranch] = []
	for i in range(params.rec_level+1):
		var skeleton = tree_skeleton.generate_skeleton(level_branches)
		level_branches = skeleton
		for branch in skeleton:
			generate_mesh(branch)


func generate_mesh(branch: TreeBranch):
	var mesh = MeshInstance3D.new()
	var array_mesh = tree_mesh_generator.generate_skin(branch)
	var material = StandardMaterial3D.new()
	var texture = load(params.tex_path)
	material.uv1_triplanar = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color *= TEX_DARKEN
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
	var children = get_children(false)
	for child in children:
		if child is StaticBody3D:
			child.queue_free()
	generate_tree()
