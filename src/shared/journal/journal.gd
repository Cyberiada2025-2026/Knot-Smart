extends Node

var prev_mouse_mode

var entry_scene = preload("uid://dktjlwqp00lcr")

var pages: Control
var buttons: Control
@onready var button_normal = $"Button container/Button".get_theme_stylebox("normal", "Button")

func add_object(obj_des:ObjectDescription):
	var page = pages.get_child(obj_des.page).get_child(1).get_child(0)
	var entry = entry_scene.instantiate()
	entry.add_entry(obj_des)
	var entry_text=entry.get_child(1)
	
	var journal_entries = get_tree().get_nodes_in_group("journal_text")
		
	for journal_text in journal_entries:
		if journal_text.get_text() == entry_text.get_text():
			entry.free()
			return
		
	page.add_child(entry)
	
	var current_page_journal_entries: Array[RichTextLabel]
	
	for journal_text in journal_entries:
		if journal_text.get_parent().get_parent() == page:
			current_page_journal_entries.append(journal_text)
	
	for journal_text in current_page_journal_entries:
		if journal_text.get_text() < entry_text.get_text():
			move_child(entry,journal_text.get_parent().get_index())
			return

#Right now, we don't need to add text entries after certain triggers (like, seeing something or discovering something) so the only way to trigger this is through this code, but in future, I will add class like ObjectDescription but for adding text entries instead of journal entries
func add_text_entry(text: String, add_number:bool): 
	var page = $"Page container/Page1/ScrollContainer/VBoxContainer"
	var entry: RichTextLabel = RichTextLabel.new()
	entry.set_custom_minimum_size(Vector2(200,0))
	entry.fit_content = true
	entry.push_color(Color(1,0,1))
	entry.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	page.add_child(entry)
	if add_number:
		entry.add_text("Entry " + str(entry.get_index()) + ": ")
	entry.add_text(text)
	
func _ready() -> void:
	pages = $"Page container"
	buttons = $"Button container"
	add_text_entry("This is journal, on this page you have aliens thoughts as entries meanwhile on others you will have object descriptions as entries",0)
	add_text_entry("me crashed, me sad",1)
	add_text_entry("me saw monster, me scared",1)

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
