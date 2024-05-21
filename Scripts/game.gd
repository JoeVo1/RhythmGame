extends Node2D

@onready var conductor = $Conductor
@onready var songSelection = preload("res://Scripts/SongSelection.gd")
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
# Called when the node enters the scene tree for the first time.
func _ready():
	$Doors.set_process(false)
	$Transition.play("fade_in")
	conductor.volume_db = SaveSettings.readData().audio
	for file in DirAccess.get_files_at(path):
		if(file.ends_with(".ogg")):
			songPath = path + '/' + file
		elif(file.ends_with(".json")):
			dataPath = path + '/' + file
	songData = parseFile(dataPath)
	conductor.loadSong(songPath,bpm,delay)
	$TextureProgressBar.max_value = conductor.song_length
	color *= 0.2
	color.a = 1
	$Doors/Top.self_modulate = color
	$Doors/Bottem.self_modulate = color

func _unhandled_input(event):
	if(event.is_action_pressed("ui_cancel")):
		conductor.stream_paused = true
		note_.pause = true
		$Panel.visible = true
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			conductor.volume_db += 1.04
			$VolumeBar.value = conductor.volume_db
			showVolumeBar()
			return
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			conductor.volume_db -= 1.04
			$VolumeBar.value = conductor.volume_db
			showVolumeBar()

func _on_conductor_beat(position):
	if(maxBeats == currentBeat):
		return
	var note = songData[currentBeat]
	if note.beat - approachRate <= position:
		spawnNote(int(note.lane), note.label)
		currentBeat +=1
	if(maxBeats > currentBeat - 1):
		return
	while note.beat == songData[currentBeat + 1].beat:
		spawnNote(int(songData[currentBeat + 1].lane), songData[currentBeat + 1].label)
		currentBeat +=1

func _physics_process(delta):
	$TextureProgressBar.value = conductor.song_position
	$FPSCounter.text = "FPS:\n" + str(Engine.get_frames_per_second())

func updateScore():
	$ComboLabel.text = str(accuracy.combo)
	$AccuracyLabel.text = str(accuracy.TotalScore / accuracy.notesHit)

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
	SaveSettings.writeData(conductor.volume_db)
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
	SaveSettings.writeData(conductor.volume_db)
	$Doors.set_process(true)
	$Doors.closeDoors()

func showVolumeBar() -> void:
	$VolumeBar.visible = true
	$Timer.wait_time = (1)
	$Timer.start()
	await $Timer.timeout
	$VolumeBar.visible = false
