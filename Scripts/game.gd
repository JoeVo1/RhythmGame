extends Node2D

@onready var conductor = $Conductor
var songSelection = load("res://Scenes/SongSelection.tscn")
var path
var songPath
var dataPath
var Note = preload("res://Prefabs/note.tscn")
var accuracy = Collider
var NoteInstance
var bpm
var songData
var currentBeat = 0
var maxBeats
var delay
var color: Color
var approachRate = 2
var changingScene = false
var prevVol
# Called when the node enters the scene tree for the first time.
func _ready():
	$Doors.set_process(false)
	$Transition.play("fade_in")
	var data = SaveSettings.readData()
	AudioServer.set_bus_volume_db(0, data.master)
	AudioServer.set_bus_volume_db(1, data.music)
	AudioServer.set_bus_volume_db(2, data.sfx)
	$VolumeBar.value = AudioServer.get_bus_volume_db(0)
	for file in DirAccess.get_files_at(path):
		if(file.ends_with(".ogg")):
			songPath = path + '/' + file
		elif(file.ends_with(".json")):
			dataPath = path + '/' + file
	songData = parseFile(dataPath)
	conductor.loadSong(songPath,bpm,delay)
	$TextureProgressBar.max_value = conductor.song_length - 2
	color *= 0.2
	color.a = 1
	$Doors/DoorAni/Top.self_modulate = color
	$Doors/DoorAni/Bottem.self_modulate = color

func _unhandled_input(event):
	if(event.is_pressed() && event.as_text().length() == 1):
		$BackGrounds/ColliderBg.self_modulate.a = 0.05
	else:
		$BackGrounds/ColliderBg.self_modulate.a = 0
	if(event.is_action_pressed("ui_cancel")):
		conductor.stream_paused = true
		note_.pause = true
		$Panel.visible = true
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			AudioServer.set_bus_volume_db(0, $VolumeBar.value + 1.04)
			$VolumeBar.value = AudioServer.get_bus_volume_db(0)
			showVolumeBar()
			return
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			AudioServer.set_bus_volume_db(0, $VolumeBar.value -1.04)
			$VolumeBar.value = AudioServer.get_bus_volume_db(0)
			showVolumeBar()

func _on_conductor_beat(position):
	if(maxBeats <= currentBeat):
		return
	var note = songData[currentBeat]
	if note.beat - approachRate <= position:
		spawnNote(int(note.lane), note.label)
		currentBeat +=1
		if(!songData.has(currentBeat)):
			return
		if(note.beat == songData[currentBeat].beat):
			spawnNote(int(songData[currentBeat].lane), songData[currentBeat].label)
	if(maxBeats < currentBeat - 1):
		return

func _physics_process(delta):
	$TextureProgressBar.value = conductor.song_position

func updateScore():
	$ComboLabel.text = 'x' + str(accuracy.combo)
	$AccuracyLabel.text = str(accuracy.TotalScore / accuracy.notesHit) + '%'

func spawnNote(lane, _char):
	NoteInstance = Note.instantiate()
	$Notes.add_child(NoteInstance)
	NoteInstance.initialize(lane, _char, approachRate)

func parseFile(_path):
	var file = FileAccess.open(_path, FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	data = JSON.parse_string(data)
	color = str_to_var(data.color)
	bpm = data.bpm
	delay = data.delay
	maxBeats = (data.charts[0].notes).size()
	if data.has("sorted"):
		return data.charts[0].notes
	data.charts[0].notes.sort_custom(customSort)
	data.sorted = true
	for note in data.charts[0].notes:
		if(note.label == ""):
			note.label = "a"
	FileAccess.open(_path, FileAccess.WRITE).store_string(JSON.stringify(data))
	return data.charts[0].notes

func customSort(a,b):
	return a.beat < b.beat

func _on_back_btn_button_down():
	if(changingScene):
		return
	changingScene = true
	SaveSettings.writeData()
	$Transition.play("fade_out")
	await $Transition.animation_finished
	get_tree().current_scene = self
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_cancel_btn_button_down():
	conductor.stream_paused = false
	note_.pause = false
	$Panel.visible = false

func _on_conductor_song_finished():
	$FinishTimer.wait_time = conductor.sec_per_beat * 4
	$FinishTimer.start()
	await $FinishTimer.timeout
	SaveSettings.writeData()
	$Doors.set_process(true)
	$Doors.closeDoors()

func showVolumeBar() -> void:
	$VolumeBar.visible = true
	$Timer.wait_time = (1)
	$Timer.start()
	await $Timer.timeout
	$VolumeBar.visible = false


func _on_back_to_song_list_btn_pressed():
	if(changingScene):
		return
	changingScene = true
	SaveSettings.writeData()
	$Transition.play("fade_out")
	await $Transition.animation_finished
	var instance = songSelection.instantiate()
	instance.changeGameScene(0)
	get_parent().add_child(instance)
	queue_free()
