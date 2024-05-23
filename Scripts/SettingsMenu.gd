extends Control


func _on_music_slider_value_changed(value):
	SaveSettings.musicVol = linear_to_db(value)
	AudioServer.set_bus_volume_db(3,value)
	SaveSettings.writeData()


func _on_sfx_slider_value_changed(value):
	SaveSettings.SFXVol = linear_to_db(value)
	AudioServer.set_bus_volume_db(2,value)
	SaveSettings.writeData()


func _on_master_slider_value_changed(value):
	SaveSettings.masterVol = linear_to_db(value)
	AudioServer.set_bus_volume_db(0,value)
	SaveSettings.writeData()
