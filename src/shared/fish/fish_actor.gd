extends CharacterBody3D


@export var speed := 30000

var can_move := false
var world: World3D

func _ready() -> void:
	world = Engine.get_main_loop().root.get_world_3d()
	
func _physics_process(_delta: float) -> void:
	var cur_loc := global_transform.origin
	var next_loc := global_transform.origin * 5
	var next_vel := (next_loc - cur_loc).normalized() * speed
	velocity = next_vel
	move_and_slide()
