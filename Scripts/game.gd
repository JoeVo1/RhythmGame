extends Node2D

@onready var conductor = $Conductor
@onready var songSelection = preload("res://Scripts/SongSelection.gd")
var path
var songPath
var dataPath
var Note = preload("res://Prefabs/note.tscn")
var accuracy = preload("res://Scripts/noteCollider.gd")
var NoteInstance
var bpm
var songData
var currentBeat = 0
var maxBeats
var delay
var approachRate = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	for file in DirAccess.get_files_at(path):
		if(file.ends_with(".ogg")):
			songPath = path + '/' + file
		elif(file.ends_with(".json")):
			dataPath = path + '/' + file
	songData = parseFile(dataPath)
	conductor.loadSong(songPath,bpm,delay)
	$TextureProgressBar.max_value = conductor.song_length

func _unhandled_input(event):
	if(event.is_action_pressed("ui_cancel")):
		$Panel.visible = true

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
	add_child(NoteInstance)
	NoteInstance.initialize(lane, _char, approachRate)

func parseFile(_path):
	var file = FileAccess.open(_path, FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	data = JSON.parse_string(data)
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
	get_tree().current_scene = self
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_cancel_btn_button_down():
	$Panel.visible = false
