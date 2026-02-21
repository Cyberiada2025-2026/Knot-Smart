extends Node

@export var rope: RopeVFX

var length = 2.0;

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			length = 2.0
			rope.start(length)
		elif event.keycode == KEY_E:
			length+=.2
			rope.set_length(length)
		elif event.keycode == KEY_Q:
			length-=.2
			rope.set_length(length)
		elif event.keycode == KEY_R:
			rope.end()
