extends Node3D
class_name RopeVFX

# Set this prefab at one end of the rope, rotate it
# so that its y-axis points at the other end
# and call start() with starting lengths

const start_length_param: String = "length_start"
const length_param: String = "length_curr"
const anim_on: String = "rope_on"
const anim_off: String = "break"

@export var player: AnimationPlayer
@export var mesh: CylinderMesh
@export var mesh_node: Node3D
@export var mat: ShaderMaterial
@export var splash: CPUParticles3D
@export var break1: CPUParticles3D
@export var break2: CPUParticles3D
@export var first_ball: Node3D
@export var second_ball: Node3D

var length_curr: float = 10.0;

## Call when creating rope
func start(start_length: float):
	mat.set_shader_parameter(start_length_param, start_length)
	set_length(start_length)
	player.play(anim_on)

## Call when rope changes length
func set_length(length: float):
	length_curr = length
	mat.set_shader_parameter(length_param, length)
	splash.emission_box_extents.y = length/2*0.6
	splash.position.y = length*0.4
	break1.emission_box_extents.y = length/2
	break2.emission_box_extents.y = length/2
	first_ball.position.y = length/2
	second_ball.position.y = -length

func end() -> void:
	player.play(anim_off)
	self.reparent(get_tree().root)
	await get_tree().create_timer(5.0).timeout
	queue_free()
