extends Control

var songSelection = load("res://Scenes/SongSelection.tscn")

func _on_play_btn_button_down():
	var instance = songSelection.instantiate()
	instance.changeGameScene(0)
	get_parent().add_child(instance)
	queue_free()


func _on_edit_btn_button_down():
	var instance = songSelection.instantiate()
	instance.changeGameScene(1)
	get_parent().add_child(instance)
	queue_free()


func _on_settings_btn_button_down():
	pass # Replace with function body.


func _on_quit_btn_button_down():
	get_tree().quit()
