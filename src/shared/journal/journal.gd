extends Node

var prev_mouse_mode

var entry_scene = preload("uid://dktjlwqp00lcr")

var pages: Control
var buttons: Control
@onready var button_normal = $"Button container/Button".get_theme_stylebox("normal", "Button")

func add_object(obj_des:ObjectDescription):
	var page = pages.get_child(obj_des.page_no).get_child(1).get_child(0)
	var entry = entry_scene.instantiate()
	entry.add_entry(obj_des)
	var entry_text=entry.get_child(1)
	
	var journal_entries = get_tree().get_nodes_in_group("journal_text")
		
	for journal_text in journal_entries:
		if journal_text.get_text() == entry_text.get_text():
			return
		
	page.add_child(entry)
	
	var current_page_journal_entries: Array[RichTextLabel]
	
	for journal_text in journal_entries:
		if journal_text.get_parent().get_parent() == page:
			current_page_journal_entries.append(journal_text)
	
	for journal_text in current_page_journal_entries:
		if journal_text.get_text() > entry_text.get_text():
			move_child(entry,journal_text.get_parent().get_index())
			return
			

func _ready() -> void:
	pages = $"Page container"
	buttons = $"Button container"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("journal_show"):
		if not (get_tree().paused == true and self.visible == false):
			if self.visible == true:
				get_tree().paused = false
				self.visible = false
				Input.set_mouse_mode(prev_mouse_mode)
			else:
				get_tree().paused = true
				self.visible = true
				prev_mouse_mode = Input.get_mouse_mode()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed(number: int) -> void:
	var button: Button = buttons.get_child(number)
	if pages.get_child(number).visible == false:
		for i in range(pages.get_child_count()):
			pages.get_child(i).set_visible(false)
			buttons.get_child(i).add_theme_stylebox_override("normal", button_normal)
		pages.get_child(number).set_visible(true)
		button.add_theme_stylebox_override("normal", button.get_theme_stylebox("pressed", "Button"))
