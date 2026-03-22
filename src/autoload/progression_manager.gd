extends Node

@export var max_death_count: int = 2

var respawn_pos: Vector3
var _death_count: int = 0


func record_death():
	_death_count += 1
	if _death_count == max_death_count:
		game_over()


func game_over():
	SceneManager.goto_scene("res://ui/game_over/game_over.tscn")
