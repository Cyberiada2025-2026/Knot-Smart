@tool
class_name FoliageGenerator
extends Node3D

const DIR_PATH = "user://foliage"

@export_tool_button("Generate", "Callable") var generate_button = on_generate
@export var params: FoliageParameters
var foliage: Node3D
var foliage_scene: PackedScene
var random = RandomNumberGenerator.new()


func _ready() -> void:
	var result = Serializer.load(DIR_PATH, params)
	if result != null:
		add_child(result)
	else:
		on_generate()


func set_params(new_params, new_transform):
	params = new_params
	transform = new_transform


func generate_foliage():
	foliage = Node3D.new()
	foliage.name = "foliage"
	var angle = PI / params.count
	var new_scale = params.scale + (random.randf() - 0.5) * params.scale_randomization
	for i in range(params.count):
		var mesh = params.mesh.instantiate()
		mesh.scale *= new_scale
		mesh.rotate_y(angle * i)
		foliage.add_child(mesh)
		mesh.owner = foliage
	serialize()


func on_generate():
	random.seed = params.seed
	foliage_scene = PackedScene.new()
	for child in get_children():
		child.queue_free()
	generate_foliage()


func serialize():
	var read_foliage = Serializer.serialize(foliage_scene, foliage, DIR_PATH, params)
	add_child(read_foliage)
	read_foliage.owner = owner
