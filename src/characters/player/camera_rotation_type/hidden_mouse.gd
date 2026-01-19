extends BaseCameraRotationType

@export var rotation_speed: float = 0.004

func rotate_with_mouse(camera: PlayerCamera, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotate_left_right(camera.get_normal(), -event.relative.x * rotation_speed)
		if camera.person_type == camera.PersonType.PERSON1:
			camera.rotate_up_down(-event.relative.y * rotation_speed)
