extends ControlStrategyInterface

enum State { SELECT_FIRST, SELECT_SECOND }

@export var rope_params = RopeParams.new()

var state = State.SELECT_FIRST
var selected_objects: Array[Node] = []
var markers: Array[MeshInstance3D] = []
var sphere: MeshInstance3D = preload("uid://ymb8m1pspwfy").instantiate()


func use_rope(raycast_result: Dictionary) -> void:
	if raycast_result.is_empty() or raycast_result.collider.get_parent() is Rope:
		return

	match state:
		State.SELECT_FIRST:
			markers.append(
				ControlStrategyUtilities.create_marker_from_unsafe_raycast(raycast_result, sphere)
			)
			selected_objects.append(raycast_result.collider)
			state = State.SELECT_SECOND

		State.SELECT_SECOND:
			markers.append(
				ControlStrategyUtilities.create_marker_from_unsafe_raycast(raycast_result, sphere)
			)
			selected_objects.append(raycast_result.collider)
			_create_rope()
			state = State.SELECT_FIRST


func break_rope(raycast_result: Dictionary) -> void:
	if raycast_result.is_empty():
		return

	if raycast_result.collider.get_parent() is Rope:
		raycast_result.collider.get_parent().finish()


func fuse(raycast_result: Dictionary) -> void:
	if raycast_result.is_empty():
		return

	if raycast_result.collider.get_parent() is Rope:
		raycast_result.collider.get_parent().fuse()


func select_player(_raycast_result: Dictionary) -> void:
	if state != State.SELECT_SECOND:
		return

	var player = get_node("../..")
	markers.append(ControlStrategyUtilities.create_marker_on_player(player, sphere))
	selected_objects.append(player)
	_create_rope()
	state = State.SELECT_FIRST


func _create_rope() -> void:
	add_child(ControlStrategyUtilities.create_rope(rope_params, selected_objects, markers))

	selected_objects = []
	markers = []
