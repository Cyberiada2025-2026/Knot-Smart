extends Node

@export var pages: Node
@export var text_page_last_container: Node
@export var items_page_last_container: Node
@export var objects_page_last_container: Node
@export var mobs_page_last_container: Node
var prev_mouse_mode
var buttons: Control
var page_visible_index: int
var page_dict: Dictionary[int, Node]
var entry_scene = preload("uid://dktjlwqp00lcr")
var entry_text = preload("uid://y7wfem0trjrv")
@onready var button_normal = $"Button container/Button".get_theme_stylebox("normal", "Button")


func add_object(obj_des: JournalEntryPOI):
	var page = page_dict[obj_des.page]
	var entry = entry_scene.instantiate()
	entry.add_entry(obj_des)
	var entry_text = entry.text

	var journal_entries = get_tree().get_nodes_in_group("journal_text")

	for journal_text in journal_entries:
		if journal_text.get_text() == entry_text.get_text():
			print("entry" + entry_text.get_text() + "already exists")
			entry.free()
			return

	page.add_child(entry)


func add_text_entry(text: String):
	var page = text_page_last_container
	var entry = entry_text.instantiate()
	page.add_child(entry)
	entry.add_text(text)


func _ready() -> void:
	buttons = $"Button container"
	page_dict = {
		0: text_page_last_container,
		1: items_page_last_container,
		2: objects_page_last_container,
		3: mobs_page_last_container
	}

	add_text_entry(
		(
			"This is journal, on this page you have aliens thoughts as"
			+ " entries meanwhile on others you will have object"
			+ " descriptions as entries"
		)
	)
	page_visible_index = 0


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("journal_toggle"):
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

	for button_no in range(buttons.get_child_count()):
		if buttons.get_child(button_no).visible == false:
			if not (page_dict[button_no].get_children().is_empty()):
				buttons.get_child(button_no).visible = true


func _on_button_pressed(number: int) -> void:
	var button: Button = buttons.get_child(number)
	if page_visible_index != number:
		pages.get_child(page_visible_index).set_visible(false)
		buttons.get_child(page_visible_index).add_theme_stylebox_override("normal", button_normal)
		pages.get_child(number).set_visible(true)
		button.add_theme_stylebox_override("normal", button.get_theme_stylebox("pressed", "Button"))
		page_visible_index = number
