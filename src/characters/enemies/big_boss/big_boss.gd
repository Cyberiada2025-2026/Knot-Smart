class_name BigBoss
extends AnimatableBody3D

@export var movement_animation: AnimationPlayer
@export_file_path(".tscn") var win_scene
@export_file_path(".tscn") var lose_scene
@export var boss_model: Node3D
@export var health_component: HealthComponent
var animation_player: AnimationPlayer

var is_battle: bool = false
var last_pos: Vector3 = Vector3()

func _ready() -> void:
	animation_player = boss_model.find_child("AnimationPlayer")
	animation_player.play("Laying")
	health_component.is_protected = true
	last_pos = position


func _on_start_boss_battle() -> void:
	get_node("BossHealth").visible = true
	health_component.is_protected = false
	animation_player.play("Walk")
	movement_animation.play("move_to_gen")

	is_battle = true
	get_tree().create_timer(120.0).timeout.connect(destroy_generator)


func _on_health_component_health_depleted() -> void:
	print("Big boss killed, you won")

	get_tree().change_scene_to_file(win_scene)


func destroy_generator() -> void:
	print("You lost")
	get_tree().change_scene_to_file(lose_scene)


func _physics_process(_delta: float) -> void:
	if is_battle:
		look_at(Vector3(40.5, position.y, -16.5))
		last_pos = position
