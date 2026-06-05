extends Control

var current_button_no: int
var entries_list: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_button_no = -1
	entries_list = get_node("Entries")

func _on_button_pressed(button_no: int) -> void:
	if current_button_no != button_no:
		if current_button_no != -1:
			entries_list.get_child(current_button_no).visible = false
		
		entries_list.get_child(button_no).visible = true
		current_button_no = button_no
