@tool
class_name TreeGenerator
extends Node3D


const TEX_DARKEN = 0.5

@export_tool_button("Generate", "Callable") var generate_button = on_generate_click
@export var params: TreeParameters

var tree_skeleton: TreeSkeleton
var tree_mesh_generator: TreeMeshGenerator
var tree: StaticBody3D


func _ready() -> void:
	generate_tree()


func generate_tree():
	tree = StaticBody3D.new()
	add_child(tree)
	#	skeleton - blueprint for mesh
	var skeleton = tree_skeleton.generate_skeleton(params)
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
	tree.add_child(mesh)
	var collision = CollisionShape3D.new()
	collision.shape = mesh.mesh.create_convex_shape()
	tree.add_child(collision)


func on_generate_click():
	tree.queue_free()
	generate_tree()
