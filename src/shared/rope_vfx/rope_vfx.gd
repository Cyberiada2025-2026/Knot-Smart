class_name RopeVFX
extends Node3D

# Set this prefab at one end of the rope, rotate it
# so that its y-axis points at the other end
# and call start() with starting lengths

const START_LENGTH_PARAM: String = "length_start"
const LENGTH_PARAM: String = "length_curr"
const ANIM_ON: String = "rope_on"
const ANIM_OFF: String = "break"

@export var player: AnimationPlayer
@export var mesh: CylinderMesh
@export var mesh_node: Node3D
@export var mat: ShaderMaterial
@export var splash: CPUParticles3D
@export var break1: CPUParticles3D
@export var break2: CPUParticles3D
@export var first_ball: Node3D
@export var second_ball: Node3D

var length_curr: float = 10.0


## Call when creating rope
func start(start_length: float):
	mat.set_shader_parameter(START_LENGTH_PARAM, start_length)
	set_length(start_length)
	player.play(ANIM_ON)


## Call when rope changes length
func set_length(length: float):
	length_curr = length
	mat.set_shader_parameter(LENGTH_PARAM, length)
	splash.emission_box_extents.y = length / 2 * 0.6
	splash.position.y = length * 0.4
	break1.emission_box_extents.y = length / 2
	break2.emission_box_extents.y = length / 2
	first_ball.position.y = length / 2
	second_ball.position.y = -length


func end() -> void:
	player.play(ANIM_OFF)
	self.reparent(get_tree().root)
	await get_tree().create_timer(5.0).timeout
	queue_free()
