extends Node2D

@onready var conductor = $Conductor
@onready var songSelection = preload("res://Scripts/SongSelection.gd")
var mainMenu = preload("res://Scenes/main_menu.tscn")
var path
var songPath
var dataPath
var Note = preload("res://Prefabs/edit_note.tscn")
var stats = preload("res://Scripts/noteCollider.gd")
var Marker = preload("res://Prefabs/marker.tscn")
var NoteGUI = preload("res://Prefabs/note_gui.tscn")
var markerOffset = 80
var beatOffset = 3
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
var editorNotes: Dictionary
var playFrom = 0
var selectedNote
var SelectorColor = null
var saveFolder = null
var ended = false
var levelName = ""
var saved = true

func _ready():
	if(path == "user://Songs/New Map"):
		bpm = 100
		delay = 0
	else:
		$UI/LevelName.editable = false
		$UI/LevelName.text = levelName
		for file in DirAccess.get_files_at(path):
			if(file.ends_with(".ogg")):
				songPath = path + '/' + file
			elif(file.ends_with(".json")):
				dataPath = path + '/' + file
		if(dataPath == null):
			FileAccess.open(path + '/' + "data.json", FileAccess.WRITE)
			dataPath = path + '/' + "data.json"
		songData = parseFile(dataPath)
		conductor.loadSong(songPath,bpm,delay)
		maxBeats = conductor.song_length_in_beats
		conductor.stream_paused = true
		EditNote.frozen = true
		$UI/ScrollContainer/HBoxContainer/ColorRect.custom_minimum_size.x = (maxBeats * markerOffset)
		$UI/FileBtn.text = songPath.get_file()
		$UI/TextureProgressBar.max_value = maxBeats
		for note in songData:
			var Instance = NoteGUI.instantiate()
			Instance.beat = note.beat
			Instance.lane = note.lane
			Instance.changeLabel(note.label)
			allNotes[int(note.beat)] = Instance
			$UI/ScrollContainer/HBoxContainer/Node2D.add_child(Instance)
			Instance.position.x = markerOffset * note.beat + 30
	$UI/BPM.value = bpm
	$UI/Delay.value = delay
	for value in 60:
		var Instance = Marker.instantiate()
		Instance.pos = value
		$UI/Markers.add_child(Instance)
		Instance.position.x = markerOffset * value + 30
		Instance.position.y -= 108
	$UI/Markers.get_children()[beatOffset].texture = load("res://Assets/Marker01.png")
	AudioServer.set_bus_volume_db(0, SaveSettings.masterVol)
	AudioServer.set_bus_volume_db(1, SaveSettings.musicVol)
	AudioServer.set_bus_volume_db(2, SaveSettings.SFXVol)
	$UI/VolumeBar.value = AudioServer.get_bus_volume_db(0)
	$Transition.play("fade_in")

func _physics_process(_delta):
	$UI/FPSCounter.text = "FPS:\n" + str(Engine.get_frames_per_second())
	$UI/TextureProgressBar.value = pos
	if(conductor.playing):
		$UI/TextureProgressBar.value = currentBeat
		$UI/ScrollContainer.scroll_horizontal = conductor.song_position / conductor.sec_per_beat * markerOffset - markerOffset * 4 - 4 * markerOffset + 30

func _unhandled_input(event):
	if($Transition.is_playing()):
		return
	if(event is InputEventMouseButton && event.is_pressed()):
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			moveBar(1)
			return
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			moveBar(-1)

func _unhandled_key_input(event):
	if($Transition.is_playing()):
		return
	if(event.as_text() == "Space" && event.is_pressed()):
		if(!conductor.stream_paused):
			conductor.stream_paused = true
			EditNote.pause = true
			$UI/ScrollContainer.scroll_horizontal = playFrom
			ended = false
			return
		currentBeat = pos + beatOffset
		playFrom = pos * markerOffset
		EditNote.frozen = false
		EditNote.pause = false
		editorNotes.clear()
		for node in $Notes.get_children():
			node.queue_free()
		conductor.play_from_beat(pos)
	if(event.as_text() == "Equal"):
		AudioServer.set_bus_volume_db(0, $UI/VolumeBar.value + 1.04)
		$UI/VolumeBar.value = AudioServer.get_bus_volume_db(0)
		showVolumeBar()
		return
	if(event.as_text() == "Minus"):
		AudioServer.set_bus_volume_db(0, $UI/VolumeBar.value -1.04)
		$UI/VolumeBar.value = AudioServer.get_bus_volume_db(0)
		showVolumeBar()
	if(event.is_action_pressed("ui_cancel")):
		if(selectedNote != null):
			selectNote(selectedNote, false)
			selectedNote = null
			return
		if(songPath == null):
			$UI/Panel.visible = !$UI/Panel.visible
		elif(!conductor.stream_paused || ended):
			conductor.stream_paused = true
			EditNote.pause = true
			EditNote.frozen = true
			$UI/ScrollContainer.scroll_horizontal = playFrom
			ended = false
		else:
			$UI/Panel.visible = !$UI/Panel.visible
	if(conductor.playing):
		return
	if(selectedNote != null):
		if(event.as_text().length() > 1):
			return
		allNotes[selectedNote].changeLabel(event.as_text())
		if(editorNotes.has(selectedNote)):
			editorNotes[selectedNote].changeLabel(event.as_text())
		return
	if(event.is_action_pressed("ui_left")):
		moveBar(-1)
	if(event.is_action_pressed("ui_right")):
		moveBar(1)
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

func Zoom(value):
	markerOffset += value
	var j = 0
	for i in $UI/Markers.get_children():
		i.position.x = markerOffset * j + 30
		j += 1
	for i in $UI/ScrollContainer/HBoxContainer/Node2D.get_children():
		i.position.x = markerOffset * i.beat + 30
	$UI/ScrollContainer/HBoxContainer/ColorRect.custom_minimum_size.x = (maxBeats * markerOffset)
	$UI/ScrollContainer.scroll_horizontal = pos * markerOffset

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
	editorNotes[int(beat)] = Instance
	spawnEditorNotes()
	Instance.position.x = markerOffset * beat + 30
	saved = false

func RemoveNote(markerPos, relative):
	if(conductor.playing):
		return
	var beat = markerPos
	if(relative):
		beat = pos + markerPos
	if(not allNotes.has(beat)):
		return
	if(selectedNote == beat):
		selectedNote = null
	allNotes[beat].queue_free()
	allNotes.erase(beat)
	if(editorNotes.has(beat) && is_instance_valid(editorNotes[beat])):
		editorNotes[beat].queue_free()
		editorNotes.erase(beat)
	saved = false

func selectNote(beat, on):
	if(selectedNote != null):
		allNotes[selectedNote].selectNote(false)
		if(editorNotes.has(selectedNote)):
			editorNotes[selectedNote].selectNote(false)
	selectedNote = beat
	allNotes[beat].selectNote(on)
	if(editorNotes.has(beat)):
		editorNotes[beat].selectNote(on)

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

func updateScore():
	$UI/ComboLabel.text = str(stats.combo)
	$UI/AccuracyLabel.text = str(stats.TotalScore / stats.notesHit)

func spawnNote(lane, _char):
	NoteInstance = Note.instantiate()
	$Notes.add_child(NoteInstance)
	NoteInstance.initialize(lane, _char, approachRate)

func parseFile(_path):
	var file = FileAccess.open(_path, FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	data = JSON.parse_string(data)
	bpm = data.bpm
	delay = data.delay
	$UI/ColorPicker.color = str_to_var(data.color)
	SelectorColor = str_to_var(data.color)
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
		data["color"] = var_to_str(SelectorColor)
	else:
		data["color"] = var_to_str(Color(1,1,1,1))
	if(path == "user://Songs/New Map"):
		if($UI/LevelName.text == "" || $UI/LevelName.text == null):
			SendError("error - add level name")
			return
		if(songPath == null):
			SendError("error - add song")
			return
		path = "user://Songs/" + $UI/LevelName.text
		var dir = DirAccess.make_dir_absolute(path)
		var file = FileAccess.open(path + "/data.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
		var newSongFile = FileAccess.open(path + "/song.ogg", FileAccess.WRITE)
		var songfile = FileAccess.open(songPath, FileAccess.READ)
		var buffer = songfile.get_buffer(songfile.get_length())
		newSongFile.store_buffer(buffer)
		dataPath = path + "/data.json"
		$UI/LevelName.editable = false
	else:
		var file = FileAccess.open(dataPath, FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
	saved = true
	return true

func moveBar(value: int):
	pos += value
	pos = clampi(pos, 0, maxBeats)
	$UI/ScrollContainer.scroll_horizontal = markerOffset * pos
	spawnEditorNotes()

func spawnEditorNotes():
	editorNotes.clear()
	pos += 3
	for node in $Notes.get_children():
		node.queue_free()
	var i = 0
	var max = pos + 7
	var _offset = 3
	while true:
		if(allNotes.has(pos + i)):
			if(allNotes[pos + i].beat < max):
				getPos(pos + i)
				i+=1
			else:
				break
		else:
			if(allNotes.is_empty() || i > allNotes.values().back().beat):
				break
			i+=1
	pos -= 3

func getPos(_pos):
	var beat = allNotes[_pos]
	NoteInstance = Note.instantiate()
	$Notes.add_child(NoteInstance)
	NoteInstance.initialize(int(beat.lane), str(beat.label), approachRate)
	NoteInstance.changePos(pos + 7 - beat.beat)
	NoteInstance.beat = _pos
	editorNotes[_pos] = NoteInstance

func customSort(a,b):
	return a.beat < b.beat

func dropped(drag):
	if(selectedNote == null):
		return
	var on
	drag.on = true
	allNotes[selectedNote].lane = drag.i
	saved = false

func showVolumeBar() -> void:
	$UI/VolumeBar.visible = true
	$Timer.wait_time = (1)
	$Timer.start()
	await $Timer.timeout
	$UI/VolumeBar.visible = false

func _on_conductor_finished():
	ended = true
	conductor.play()
	conductor.stream_paused = true

func noteHit(hit):
	if(!conductor.playing):
		return
	if(hit):
		$SFX.PlayHitSound(true)
	else:
		$SFX.PlayHitSound(hit)

func SendError(message):
	$UI/Error.visible = true
	$UI/Error.text = message
