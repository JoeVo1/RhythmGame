extends Control
var rng = RandomNumberGenerator.new()
var songSelection = load("res://Scenes/SongSelection.tscn")

func _ready():
	$AudioVisualizer.initVolume(SaveSettings.readData().audio)
	var files = DirAccess.get_directories_at("user://Songs/")
	$AudioVisualizer.playSong(files[rng.randi_range(0,files.size() - 1)])
	$Transition.play("fade_in")

func _on_play_btn_button_down():
	$Transition.play("fade_out")
	await $Transition.animation_finished
	SaveSettings.writeData($AudioVisualizer.volume)
	var instance = songSelection.instantiate()
	instance.changeGameScene(0)
	get_parent().add_child(instance)
	queue_free()


func _on_edit_btn_button_down():
	$Transition.play("fade_out")
	await $Transition.animation_finished
	SaveSettings.writeData($AudioVisualizer.volume)
	var instance = songSelection.instantiate()
	instance.changeGameScene(1)
	get_parent().add_child(instance)
	queue_free()


func _on_settings_btn_button_down():
	pass # Replace with function body.


func _on_quit_btn_button_down():
	$Transition.play("fade_out")
	await $Transition.animation_finished
	SaveSettings.writeData($AudioVisualizer.volume)
	get_tree().quit()

func _unhandled_input(event):
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			$AudioVisualizer.setVolume(1.04)
			$VolumeBar.value = $AudioVisualizer.volume
			showVolumeBar()
			return
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			$AudioVisualizer.setVolume(-1.04)
			$VolumeBar.value = $AudioVisualizer.volume
			showVolumeBar()


func showVolumeBar() -> void:
	$VolumeBar.visible = true
	$Timer.wait_time = (1)
	$Timer.start()
	await $Timer.timeout
	$VolumeBar.visible = false
