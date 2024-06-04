extends Sprite2D

var pos
var editor

func _ready():
	editor = get_parent().get_parent().get_parent()

func _on_button_gui_input(event):
	if(editor == null):
		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				editor.AddNote(pos)
			MOUSE_BUTTON_RIGHT:
				editor.RemoveNote(pos, true)
