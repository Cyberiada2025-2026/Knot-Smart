extends Area3D

@export var kill_time: float = 10.0
@export var heal_time: float = 5.0
@export var anim_param: String = "anim"

var killing: bool = false
var radiation: float = 0.0

var rad_rect: ColorRect
var rad_mat: ShaderMaterial

func _ready() -> void:
	rad_rect = CameraSetup.get_radiation()
	rad_mat = rad_rect.material
	rad_rect. visible = false

func _process(delta: float) -> void:
	if killing:
		rad_rect.visible = true
		radiation += delta / kill_time
		if radiation >= 1.0:
			radiation = 1.0
			get_tree().get_first_node_in_group("Player").get_node("HealthComponent").health = 0.0
	elif radiation > 0.0:
		radiation -= delta / heal_time
		if radiation <= 0.0:
			radiation = 0.0
			rad_rect.visible = false
	rad_mat.set_shader_parameter(anim_param, radiation)


func _on_area_3d_area_entered(_area: Area3D) -> void:
	killing = false

func _on_area_exited(_area: Area3D) -> void:
	killing = true
