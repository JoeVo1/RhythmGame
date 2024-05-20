extends Sprite2D

var pos

func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				get_tree().root.get_child(0).AddNote(pos)
			MOUSE_BUTTON_RIGHT:
				get_tree().root.get_child(0).RemoveNote(pos)
