class_name SettingsListener
extends Node

enum Lifetime {
	NODE_LIFETIME,
	ONLY_IN_TREE,
}

var _key: Array[String]
var _callable: Callable
var _call_immediately: bool
var _lifetime: Lifetime


func _init(key: Array[String], callable: Callable, call_immediately: bool = false,
	lifetime: Lifetime = Lifetime.NODE_LIFETIME
) -> void:
	_key = key
	_callable = callable
	_call_immediately = call_immediately
	_lifetime = lifetime

func _ready() -> void:
	if _lifetime == Lifetime.NODE_LIFETIME:
		Settings.add_listener(_key, _callable, _call_immediately)
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _lifetime == Lifetime.NODE_LIFETIME:
		# Godot does not have any _on_destroy() method or similar,
		# but NOTIFICATION_PREDELETE is an equivalent
		Settings.remove_listener(_key, _callable)

func _enter_tree() -> void:
	if _lifetime == Lifetime.ONLY_IN_TREE:
		Settings.add_listener(_key, _callable, _call_immediately)
		
func _exit_tree() -> void:
	if _lifetime == Lifetime.ONLY_IN_TREE:
		Settings.remove_listener(_key, _callable)
