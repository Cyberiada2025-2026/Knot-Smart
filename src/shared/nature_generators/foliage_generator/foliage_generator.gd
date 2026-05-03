@tool
class_name FoliageGenerator
extends Node3D

const DIR_PATH = "user://foliage"

@export_tool_button("Generate", "Callable") var generate_button = on_generate
@export var params: FoliageParameters

var foliage_scene: PackedScene
var standalone: bool = true


func _init() -> void:
	standalone = false


func _ready() -> void:
	on_generate()


func generate_foliage():
	var angle = PI/params.count
	var new_scale = params.scale + (randf() - 0.5) * params.scale_randomization
	for i in range(params.count):
		var mesh = params.mesh.instantiate()
		mesh.scale *= new_scale
		mesh.rotate_y(angle*i)
		add_child(mesh)

	if standalone:
		serialize()


func on_generate():
	foliage_scene = PackedScene.new()
	for child in get_children():
		child.queue_free()
	generate_foliage()


func serialize():
	add_child(Serialize.serialize(foliage_scene, self, DIR_PATH))
