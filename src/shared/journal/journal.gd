## Manages the journal system
extends Node

var is_visible: bool = false
var menu: Control
var pages: Control
var button_normal
var added_information: Array[bool] = [0,0,0,0]

func add_mob(i: int) -> void:
	var mob_page: RichTextLabel = pages.get_child(1).get_child(1)
	match i:
		1:
			print("dodawanie obiektu 1")
			mob_page.add_text("\n to jest obiekt 1 \n nie robi nic")
		2:
			print("dodawanie obiketu 2")
			mob_page.add_text("\n to jest obiekt 2 \n robi coś")
	pass
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu = get_child(0)
	pages = menu.get_child(1)
	button_normal = menu.get_child(0).get_child(1).get_theme_stylebox("normal", "Button")
	pass # Replace with function body.

func _init() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("journal_show"):
		print("click1")
		if menu.visible == true:
			menu.visible = false
		else:
			menu.visible = true
	
	if Input.is_action_just_pressed("ui_left"):
		if added_information[0]==false:
			added_information[0]=true
			add_mob(1)
		print("dodawanie info 1")
		
	if Input.is_action_just_pressed("ui_right"):
		if added_information[1]==false:
			added_information[1]=true
			add_mob(2)
		print("dodawanie info 2")
	
	pass
	
func _physics_process(delta: float) -> void:
	pass

func _on_button_pressed(number: int) -> void:
	var button: Button = menu.get_child(0).get_child(number)
	print(number+1)
	
	if(pages.get_child(number).visible==false):
		for i in range(pages.get_child_count()):
			pages.get_child(i).set_visible(false)
			menu.get_child(0).get_child(i).add_theme_stylebox_override("normal",button_normal)
			
		pages.get_child(number).set_visible(true)
		button.add_theme_stylebox_override("normal",button.get_theme_stylebox("pressed", "Button"))
		
	pass # Replace with function body.
