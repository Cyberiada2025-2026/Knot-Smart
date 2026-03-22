@tool
class_name VfxPlayerSequence
extends Node3D

@export_tool_button("Play") var play_action = play


func play() -> void:
	var emitters = get_children().filter(func(c): return c.get("emitting") != null)
	for emitter in emitters:
		emitter.emitting = true
		await emitter.finished
