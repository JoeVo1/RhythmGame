extends Control
var rng = RandomNumberGenerator.new()
var songSelection = load("res://Scenes/SongSelection.tscn")
var files = DirAccess.get_directories_at("user://Songs/")
var SettingsMenuPos = Vector2(1920, 0)
var settings: bool = false
var changingScene = false
var len = 0

func _ready():
	$CPUParticles2D.emitting = true
	var data = SaveSettings.readData()
	AudioServer.set_bus_volume_db(0, data.master)
	$SettingsMenu/PanelContainer/VBoxContainer/MasterSlider.value = data.master
	
	$SettingsMenu/PanelContainer/VBoxContainer/MusicSlider.value = data.music
	AudioServer.set_bus_volume_db(3, data.music)
	
	$SettingsMenu/PanelContainer/VBoxContainer/SFXSlider.value = data.sfx
	AudioServer.set_bus_volume_db(2, data.sfx)
	
	$Camera2D/VolumeBar.value = AudioServer.get_bus_volume_db(0)
	PlayMusic()
	$Transition.play("fade_in")


func PlayMusic():
	if(files.is_empty() || files.size() < len):
		return
	len += 1
	$AudioVisualizer.playSong(files[rng.randi_range(0,files.size() - 1)])


func _on_play_btn_button_down():
	if(changingScene):
		return
	changingScene = true
	$Transition.play("fade_out")
	await $Transition.animation_finished
	saveSettings()
	var instance = songSelection.instantiate()
	instance.changeGameScene(0)
	get_parent().add_child(instance)
	queue_free()


func _on_edit_btn_button_down():
	if(changingScene):
		return
	changingScene = true
	$Transition.play("fade_out")
	await $Transition.animation_finished
	saveSettings()
	var instance = songSelection.instantiate()
	instance.changeGameScene(1)
	get_parent().add_child(instance)
	queue_free()


func _on_settings_btn_button_down():
	$Camera2D.position = SettingsMenuPos
	settings = true


func _on_quit_btn_button_down():
	$Transition.play("fade_out")
	await $Transition.animation_finished
	saveSettings()
	get_tree().quit()


func _unhandled_input(event):
	if(event.is_action_pressed("ui_cancel")):
		if(settings):
			$Camera2D.position = Vector2(0,0)
			settings = false
			return
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			AudioServer.set_bus_volume_db(0, AudioServer.get_bus_volume_db(0) + 1.04)
			$Camera2D/VolumeBar.value = AudioServer.get_bus_volume_db(0)
			$SettingsMenu/PanelContainer/VBoxContainer/MasterSlider.value = AudioServer.get_bus_volume_db(0)
			showVolumeBar()
			return
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			AudioServer.set_bus_volume_db(0 ,AudioServer.get_bus_volume_db(0) -1.04)
			$Camera2D/VolumeBar.value = AudioServer.get_bus_volume_db(0)
			$SettingsMenu/PanelContainer/VBoxContainer/MasterSlider.value = AudioServer.get_bus_volume_db(0)
			showVolumeBar()


func showVolumeBar() -> void:
	$Camera2D/VolumeBar.visible = true
	$Timer.wait_time = (1)
	$Timer.start()
	await $Timer.timeout
	$Camera2D/VolumeBar.visible = false

func saveSettings():
	SaveSettings.SFXVol =  $SettingsMenu/PanelContainer/VBoxContainer/SFXSlider.value
	SaveSettings.musicVol = $SettingsMenu/PanelContainer/VBoxContainer/MusicSlider.value
	SaveSettings.masterVol = AudioServer.get_bus_volume_db(0)
	SaveSettings.writeData()

func _on_back_btn_button_down():
	if(settings):
		$Camera2D.position = Vector2(0,0)
		settings = false
		return
