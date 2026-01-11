extends Node3D

class_name Player

@export_category("MODULES")
@export var playerPhysics: PlayerPhysics
@export var playerCamera: PlayerCamera
@export var playerFloorSensor: RayCast3D
@export_category("VARIABLES")
@export var rotationSpeed: float = 1.0
@export var gravityRotationSpeedModifier: float = 5.0
@export var gravityResetTime: float = 1.0

var groundNormal: Vector3 = Vector3.UP
var newGroundNormal: Vector3 = Vector3.UP
var front: Vector3 = Vector3.FORWARD
var gravityResetTimer: float = 0.0
var isRotating: bool = false


func _process(delta: float) -> void:
	#_process_camera_input(delta)
	
	##new
	_check_new_rotation(delta)
	_update_to_new_rotation(delta)
	
	



func _on_player_camera_camera_rotated(vector: Vector3, angle: float) -> void:
	front = front.rotated(groundNormal, angle)




##
## new_rotation : handle changing of player gravity
##

## set new values
func _check_new_rotation(delta: float) -> void:
	if playerPhysics.is_on_floor():
		gravityResetTimer = 0.0
		newGroundNormal = playerFloorSensor.get_collision_normal()
	else:
		gravityResetTimer += delta
	
	if gravityResetTimer >= gravityResetTime:
		newGroundNormal = Vector3.UP

## update values
func _update_to_new_rotation(delta: float) -> void:
	if groundNormal != newGroundNormal:
		isRotating = true
		var movedGroundNormal := groundNormal.move_toward(newGroundNormal, delta * gravityRotationSpeedModifier * rotationSpeed)
		var angle := groundNormal.angle_to(movedGroundNormal)
		
		playerCamera.rotate(groundNormal.cross(movedGroundNormal).normalized(), angle)
		front = front.rotated(groundNormal.cross(movedGroundNormal).normalized(), angle)
		groundNormal = movedGroundNormal
		playerPhysics.up_direction = groundNormal
		_rotate_player()
	else:
		isRotating = false

##
func _rotate_player() -> void:
	var tmp_transform := playerPhysics.global_transform
	tmp_transform.basis.y = groundNormal
	tmp_transform.basis.x = -tmp_transform.basis.z.cross(groundNormal)
	tmp_transform.basis = tmp_transform.basis.orthonormalized()
	playerPhysics.global_transform = tmp_transform

##
## END new_rotation
##




## DEV-LOG
##
#MODUŁY:
#Player - główny moduł składający całość gracza
#PlayerPhysics - moduł zajmujący się fizyką gracza
#PlayerCamera - moduł zajmujący się kamerą
#
#
#STEROWANIE:
#ui_left - ruch w kierunku - A, arrow_left
#ui_right -  ruch w kierunku - D, arrow_right
#ui_up -  ruch w kierunku - W, arrow_up
#ui_down -  ruch w kierunku - S, arrow_down
#JUMP_BUTTON - klawisz skoku - spacja
#ROTATE_CLOCK - obrót kamery - E
#ROTATE_COUNTER_CLOCK - obrót kamery - Q
#CHANGE_CAMERA - zmiana typu kamery - R
#
#
#CAMERA
#enum ROTATION_TYPE - typy używania kamery:
#QE_KEYBOARD -obrót kamerą za pomocą  ROTATE_CLOCK i ROTATE_COUNTER_CLOCK
#HIDEN_MOUSE - obrót kamerą przy poruszaniu myszką
#
#signal camera_rotated - sygnał wysyłany podczas obrotu lewo/prawo: vector - vektor obroty, angle-kąt obroty 
