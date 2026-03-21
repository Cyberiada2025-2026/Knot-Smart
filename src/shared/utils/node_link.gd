## Links parent to other node
class_name NodeLink
extends Node

var linked: Node


func _init(node: Node) -> void:
	linked = node
