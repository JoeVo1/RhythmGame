extends Sprite2D

var pos

func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				get_parent().get_parent().AddNote(pos)
			MOUSE_BUTTON_RIGHT:
				get_parent().get_parent().RemoveNote(pos, true)
