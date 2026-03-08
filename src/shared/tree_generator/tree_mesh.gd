class_name TreeMesh
extends StaticBody3D

var tree_generator: TreeGenerator
@export var params: TreeParameters
@export var pos: Vector3 = Vector3.ZERO



func _enter_tree() -> void:
	tree_generator = get_parent()
	
	
func generate_tree():
	# loop:
	#	generate one level of skeleton
	#	generate one level of mesh
	var is_branch = false
	var skeleton = tree_generator.tree_skeleton.generate_skeleton(params)
	for branch in skeleton:
		generate_mesh(branch, is_branch)
		is_branch = true


func generate_mesh(branch: Array, is_branch: bool):
	var mesh = MeshInstance3D.new()
	var array_mesh = tree_generator.tree_mesh_generator.generate_skin(branch, params, is_branch)
	var material = StandardMaterial3D.new()
	var texture = load(params.tex_path)
	material.uv1_triplanar = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color *= 0.55
	array_mesh.surface_set_material(0, material)
	mesh.mesh = array_mesh	
	add_child(mesh)
	
	var collision = CollisionShape3D.new()
	collision.shape = mesh.mesh.create_convex_shape()
	add_child(collision)
	
	return mesh
