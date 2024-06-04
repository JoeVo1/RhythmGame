extends Control
var rng = RandomNumberGenerator.new()
var songSelection = load("res://Scenes/SongSelection.tscn")
var files = DirAccess.get_directories_at("user://Songs/")
var SettingsMenuPos = Vector2(1920, 0)
var settings: bool = false
var changingScene = false
var len = 0
var lastHoveredPos = null
var blackHoleOffset

func _ready():
	blackHoleOffset = $Buttons/PlayBtn.size/2
	for button in $Buttons.get_children():
		button.mouse_entered.connect(hover.bind(button))
	var data = SaveSettings.readData()
	if !(data.has("master") || data.has("music") || data.has("particles") || data.has("sfx")):
		writeDefaultData()
		data = SaveSettings.readData()
	$SettingsMenu/PanelContainer/VBoxContainer/MasterSlider.value = data.master
	AudioServer.set_bus_volume_db(0, data.master)
	$SettingsMenu/PanelContainer/VBoxContainer/MusicSlider.value = data.music
	AudioServer.set_bus_volume_db(3, data.music)
	$SettingsMenu/PanelContainer/VBoxContainer/SFXSlider.value = data.sfx
	AudioServer.set_bus_volume_db(2, data.sfx)
	$SettingsMenu/PanelContainer2/VBoxContainer/CheckBox.button_pressed = !data.particles
	$CPUParticles2D.emitting = data.particles
	SaveSettings.enableParticles = data.particles
	
	$Camera2D/VolumeBar.value = AudioServer.get_bus_volume_db(0)
	PlayMusic()
	$Transition.play("fade_in")

func _physics_process(delta):
	if(lastHoveredPos == null):
		return
	$BlackHole.rotate(0.02)
	$BlackHole.position = lerp($BlackHole.position, lastHoveredPos, 0.3)

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
	saveSettings()
	await $Transition.animation_finished
	get_tree().quit()

func _unhandled_input(event):
	if(event.is_action_pressed("ui_cancel")):
		if(settings):
			$Camera2D.position = Vector2(0,0)
			settings = false
			return
	if(event.is_action_pressed("ui_right")):
		if(!settings):
			$Camera2D.position = SettingsMenuPos
			settings = true
		return
	if(event.is_action_pressed("ui_left")):
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

func hover(button):
	$BlackHole.visible = true
	lastHoveredPos = button.position + blackHoleOffset

func PlaySFX():
	$SFX.PlayHitSound(true)

func enableParticles():
	$CPUParticles2D.emitting = SaveSettings.enableParticles

static func writeDefaultData():
	var dic: Dictionary
	dic["master"] = 0
	dic["music"] = 0
	dic["sfx"] = 0
	dic["particles"] = true
	var file = FileAccess.open("user://Settings.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(dic))
