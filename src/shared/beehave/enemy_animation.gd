class_name EnemyAnimation
extends Node

var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player = get_node("..").find_child("AnimationPlayer")
	animation_player.play("Walk")
