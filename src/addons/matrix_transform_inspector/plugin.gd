@tool
extends EditorPlugin

var plugin = preload("uid://bddwyxv665m62")

func _enter_tree() -> void:
	plugin = plugin.new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
