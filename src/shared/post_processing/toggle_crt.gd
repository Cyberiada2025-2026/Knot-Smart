extends CanvasItem


func _ready():
	add_child(SettingsListener.new(["accessibility", "use crt filter"], _toggle_crt, true))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_crt"):
		Settings.set_value(["accessibility", "use crt filter"], !visible)


func _toggle_crt(toggled: bool):
	visible = toggled
