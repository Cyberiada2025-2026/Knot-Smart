extends Node

var _prev_mouse_mode
var _paused = false

## Pauses tree processing [br]
## additionally shows cursor
func pause_game() -> void:
	if _paused:
		return

	get_tree().paused = true
	_prev_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_paused = true


## Resumes tree processing and returns cursor to previous mode
func unpause_game() -> void:
	if not _paused:
		return

	get_tree().paused = false
	Input.set_mouse_mode(_prev_mouse_mode)

	_paused = false
