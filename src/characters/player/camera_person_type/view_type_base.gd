extends Node

class_name ViewTypeBase

@export var should_rotate_left_right: bool = false
@export var should_rotate_up_down: bool = false
@export var next_strategy: ViewTypeBase

func start(_camera: PlayerCamera) -> void:
	pass

func zoom(_camera: PlayerCamera, _delta: float) -> void:
	pass

func change_view_to(_camera: PlayerCamera, _event: InputEvent) -> void:
	pass
