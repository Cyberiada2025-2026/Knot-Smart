extends CanvasItem


func _ready():
	Settings.use_crt_filter.updated.connect(_toggle_crt)
	_toggle_crt(Settings.use_crt_filter.value)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_crt"):
		Settings.set_value(["accessibility", "use crt filter"], !visible)


func _toggle_crt(toggled: bool):
	visible = toggled
