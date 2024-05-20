extends Node2D

@onready var conductor = $Conductor
@onready var songSelection = preload("res://Scripts/SongSelection.gd")
var mainMenu = preload("res://Scenes/main_menu.tscn")
var path
var songPath
var dataPath
var Note = preload("res://Prefabs/note.tscn")
var accuracy = preload("res://Scripts/noteCollider.gd")
var Marker = preload("res://Prefabs/marker.tscn")
var NoteGUI = preload("res://Prefabs/note_gui.tscn")
@onready var Draggables = [$Colliders/NoteCollider/Draggable, $Colliders/noteCollider/Draggable, $Colliders/noteCollider2/Draggable, $Colliders/noteCollider3/Draggable]
var NoteTexture = preload("res://Assets/Note.png")
var offset = 80
var NoteInstance
var bpm
var songData
var currentBeat = 0
var maxBeats
var delay
var approachRate = 2
var zoom = 2
var pos = 0
var allNotes = {}
var playFrom = 0
var selectedNote
var SelectorColor = null
# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().files_dropped.connect(on_file_dropped)
	if(path == "user://Songs/New Map"):
		bpm = 100
		delay = 0
	else:
		for file in DirAccess.get_files_at(path):
			if(file.ends_with(".ogg")):
				songPath = path + '/' + file
			elif(file.ends_with(".json")):
				dataPath = path + '/' + file
		songData = parseFile(dataPath)
		conductor.loadSong(songPath,bpm,delay)
		maxBeats = conductor.song_length_in_beats
		conductor.stream_paused = true
		$UI/ScrollContainer/HBoxContainer/ColorRect.size.x = (conductor.song_length_in_beats * offset) + 2400
		$UI/FileBtn.text = songPath.get_file()
		
		for note in songData:
			var Instance = NoteGUI.instantiate()
			Instance.beat = note.beat
			Instance.lane = note.lane
			Instance.changeLabel(note.label)
			allNotes[int(note.beat)] = Instance
			$UI/ScrollContainer/HBoxContainer/Node2D.add_child(Instance)
			Instance.position.x = offset * note.beat + 30
	$UI/BPM.value = bpm
	$UI/Delay.value = delay
	
	for value in 60:
		var Instance = Marker.instantiate()
		Instance.pos = value
		$UI/Markers.add_child(Instance)
		Instance.position.x = offset * value + 30
		Instance.position.y -= 108


func _unhandled_key_input(event):
	if(event.is_action_pressed("ui_cancel")):
		if(selectedNote != null):
			selectNote(selectedNote, false)
			selectedNote = null
			for draggable in Draggables:
				draggable.ClearTexture()
		else:
			$UI/Panel.visible = true
		if(!conductor.stream_paused):
			conductor.stream_paused = !conductor.stream_paused
			$UI/ScrollContainer.scroll_horizontal = playFrom
	if(conductor.playing):
		return
	if(selectedNote != null):
		if(event.as_text().length() > 1):
			return
		allNotes[selectedNote].changeLabel(event.as_text())
		return
	if(event.is_action_pressed("ui_left")):
		$UI/ScrollContainer.scroll_horizontal -= offset
		if(pos == 0):
			return
		pos -=1
	if(event.is_action_pressed("ui_right")):
		$UI/ScrollContainer.scroll_horizontal += offset
		if(pos == conductor.song_length_in_beats):
			return
		pos +=1
	if(event.is_action_pressed("ui_up")):
		if(zoom == -4):
			return
		zoom -=1
		Zoom(10)
	if(event.is_action_pressed("ui_down")):
		if(zoom == 6):
			return
		zoom +=1
		Zoom(-10)
	if(event.as_text() == "Space"):
		if(!conductor.stream_paused):
			conductor.stream_paused = true
			return
		currentBeat = pos + 4
		if(currentBeat < 4):
			currentBeat = 4
		playFrom = pos * offset
		conductor.play_from_beat(pos)


func Zoom(value):
	offset += value
	var j = 0
	for i in $UI/Markers.get_children():
		i.position.x = offset * j + 30
		j += 1
	for i in $UI/ScrollContainer/HBoxContainer/Node2D.get_children():
		i.position.x = offset * i.beat + 30
	$UI/ScrollContainer.scroll_horizontal = pos * offset


func AddNote(markerPos):
	if(conductor.playing):
		return
	var beat = pos + markerPos
	if(allNotes.has(beat)):
		selectNote(beat, true)
		return
	var Instance = NoteGUI.instantiate()
	$UI/ScrollContainer/HBoxContainer/Node2D.add_child(Instance)
	Instance.beat = beat
	allNotes[int(beat)] = Instance
	Instance.position.x = offset * beat + 30


func RemoveNote(markerPos):
	if(conductor.playing):
		return
	var beat = pos + markerPos
	if(not allNotes.has(beat)):
		return
	allNotes[beat].queue_free()
	allNotes.erase(beat)


func selectNote(beat, on):
	if(selectedNote != null):
		allNotes[selectedNote].selectNote(false)
	selectedNote = beat
	allNotes[beat].selectNote(on)
	for draggable in Draggables:
		draggable.ClearTexture()
	Draggables[allNotes[beat].lane].TextureNote(NoteTexture)

func _on_conductor_beat(position):
	if(maxBeats <= currentBeat):
		return
	if(not allNotes.has(currentBeat)):
		currentBeat+=1
		return
	var note = allNotes[currentBeat]
	if note.beat - approachRate <= position:
		spawnNote(int(note.lane), note.label)
		currentBeat +=1
	if(maxBeats > currentBeat - 1):
		return
	while note.beat == songData[currentBeat + 1].beat:
		spawnNote(int(songData[currentBeat + 1].lane), songData[currentBeat + 1].label)
		currentBeat +=1

func _physics_process(_delta):
	$UI/TextureProgressBar.value = conductor.song_position
	$UI/FPSCounter.text = "FPS:\n" + str(Engine.get_frames_per_second())
	if(conductor.playing):
		$UI/ScrollContainer.scroll_horizontal = conductor.song_position / conductor.sec_per_beat * offset - offset * 4

func updateScore():
	$UI/ComboLabel.text = str(accuracy.combo)
	$UI/AccuracyLabel.text = str(accuracy.TotalScore / accuracy.notesHit)

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
	if data.has("sorted"):
		return data.charts[0].notes
	data.charts[0].notes.sort_custom(customSort)
	data.sorted = true
	for note in data.charts[0].notes:
		if(note.label == ""):
			note.label = "a"
	FileAccess.open(_path, FileAccess.WRITE).store_string(JSON.stringify(data))
	return data.charts[0].notes

func writeFile():
	var data : Dictionary
	var notes : Array
	data["bpm"] = bpm
	data["delay"] = delay
	
	for note in allNotes.values():
		var dic : Dictionary
		dic["beat"] = note.beat
		dic["label"] = note.label
		dic["lane"] = note.lane
		notes.append(dic)
	var notesDic: Dictionary
	notesDic["notes"] = notes
	data["charts"] = [notesDic]
	if(SelectorColor != null):
		data["color"] = SelectorColor
	else:
		data["color"] = var_to_str(Color(1,1,1,1))
	if(path == "user://Songs/New Map"):
		var i = 0
		while(true):
			if(DirAccess.dir_exists_absolute(path + str(i))):
				i+=1
			else:
				break
		var dir = DirAccess.make_dir_absolute(path + str(i))
		print(path + str(i))
		var file = FileAccess.open(path + str(i) + "/data.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
		return
	var file = FileAccess.open(dataPath, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func customSort(a,b):
	return a.beat < b.beat


func _on_bpm_value_changed(value):
	bpm = value
	conductor.loadSong(songPath,bpm,delay)
	conductor.stream_paused = true


func _on_delay_value_changed(value):
	delay = value
	conductor.loadSong(songPath,bpm,delay)
	conductor.stream_paused = true


func _on_approach_rate_value_changed(value):
	approachRate = value


func on_file_dropped(file):
	if(file.size() != 1):
		print("only 1")
		return
	if(!file[0].ends_with(".ogg")):
		print("incorrect File Type")
		return
	songPath = file[0]
	conductor.loadSong(songPath,bpm,delay)
	conductor.stream_paused = true
	$UI/ScrollContainer/HBoxContainer/ColorRect.size.x = (conductor.song_length_in_beats * offset) + 2400


func _on_file_btn_button_down():
	$UI/FileDialog.current_dir = "/Users"
	$UI/FileDialog.visible = !$UI/FileDialog.visible
	maxBeats = conductor.song_length_in_beats


func _on_file_dialog_file_selected(_path):
	songPath = _path
	$UI/FileBtn.text = _path.get_file()
	conductor.loadSong(songPath,bpm,delay)
	conductor.stream_paused = true
	$UI/ScrollContainer/HBoxContainer/ColorRect.size.x = (conductor.song_length_in_beats * offset) + 2400
	maxBeats = conductor.song_length_in_beats


func dropped(drag):
	var on
	for draggable in Draggables:
		if(draggable.on):
			on = draggable
			break
	on.ClearTexture()
	drag.on = true
	allNotes[selectedNote].lane = drag.i


func _on_save_btn_button_down():
	writeFile()


func _on_back_btn_button_down():
	get_tree().current_scene = self
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_cancel_btn_button_down():
	$UI/Panel.visible = false


func _on_color_picker_color_changed(color):
	SelectorColor = var_to_str(color)
