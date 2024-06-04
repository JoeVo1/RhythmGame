extends Control


func _on_music_slider_value_changed(value):
	SaveSettings.musicVol = linear_to_db(value)
	AudioServer.set_bus_volume_db(3,value)
	SaveSettings.writeData()


func _on_sfx_slider_value_changed(value):
	SaveSettings.SFXVol = linear_to_db(value)
	AudioServer.set_bus_volume_db(2,value)


func _on_master_slider_value_changed(value):
	SaveSettings.masterVol = linear_to_db(value)
	AudioServer.set_bus_volume_db(0,value)


func _on_folder_btn_button_down():
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://Songs"))


func _on_sfx_slider_drag_ended(value_changed):
	get_parent().PlaySFX()


func _on_check_box_button_down():
	SaveSettings.enableParticles = $PanelContainer2/VBoxContainer/CheckBox.button_pressed
	get_parent().enableParticles()
