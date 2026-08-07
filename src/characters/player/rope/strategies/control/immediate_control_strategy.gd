extends ControlStrategyInterface

enum State { NO_ROPE, ROPE_EXISTS }

var state = State.NO_ROPE
var sphere: MeshInstance3D = preload("uid://ymb8m1pspwfy").instantiate()
var active_rope: Rope = null

var rope_params: RopeParams


func _ready() -> void:
	rope_params = get_parent().rope_params


func use_rope(raycast_result: Dictionary) -> void:
	if raycast_result.is_empty() or raycast_result.collider.get_parent() is Rope:
		return

	var player = get_node("../..")

	match state:
		State.NO_ROPE:
			var target_marker = ControlStrategyUtilities.create_marker_from_unsafe_raycast(
				raycast_result, sphere
			)

			var player_marker = ControlStrategyUtilities.create_marker_on_player(player, sphere)

			active_rope = ControlStrategyUtilities.create_rope(
				rope_params, [raycast_result.collider, player], [target_marker, player_marker]
			)
			active_rope.finished.connect(_on_active_rope_finished)
			add_child(active_rope)
			state = State.ROPE_EXISTS

		State.ROPE_EXISTS:
			print("Yes rope")
			active_rope.change_attach_node(
				player,
				raycast_result.collider,
				ControlStrategyUtilities.create_marker(
					raycast_result.collider, raycast_result.position, sphere
				)
			)
			active_rope = null
			state = State.NO_ROPE


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
	pass


func _on_active_rope_finished():
	active_rope = null
	state = State.NO_ROPE
