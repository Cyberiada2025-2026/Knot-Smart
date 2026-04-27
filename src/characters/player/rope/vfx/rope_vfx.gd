class_name RopeVFX
extends Node3D

# Set this prefab at one end of the rope, rotate it
# so that its y-axis points at the other end
# and call start() with starting lengths

const START_LENGTH_PARAM: String = "length_start"
const LENGTH_PARAM: String = "length_curr"
const MAX_LENGTH_PARAM: String = " max_length"
const MIN_LENGTH_PARAM: String = " min_length"
const ANIM_ON: String = "rope_on"
const ANIM_OFF: String = "break"

@export var player: AnimationPlayer
@export var mesh: CylinderMesh
@export var mesh_node: Node3D
@export var mat: ShaderMaterial
@export var splash: CPUParticles3D
@export var break1: CPUParticles3D
@export var break2: CPUParticles3D


## Call when creating rope
func start(params: RopeParams):
	var neutral_length: float = (params.max_rope_length - params.min_rope_length) / 2
	mat.set_shader_parameter(MAX_LENGTH_PARAM, params.max_rope_length)
	mat.set_shader_parameter(MIN_LENGTH_PARAM, params.min_rope_length)
	mat.set_shader_parameter(START_LENGTH_PARAM, neutral_length)
	set_length(neutral_length)
	player.play(ANIM_ON)


## Call when rope changes length
func set_length(length: float):
	mat.set_shader_parameter(LENGTH_PARAM, length)
	splash.emission_box_extents.y = length / 2 * 0.6
	splash.position.y = length * 0.4
	break1.emission_box_extents.y = length / 2
	break2.emission_box_extents.y = length / 2


func end() -> void:
	player.play(ANIM_OFF)
	self.reparent(get_tree().root)
	await get_tree().create_timer(5.0).timeout
	queue_free()
