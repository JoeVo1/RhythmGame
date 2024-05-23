extends Node2D

const path = "user://Songs/"
const GUI = preload("res://Prefabs/song_gui.tscn")
const guiOffset = 140
var sceneToUse
var mainMenu = preload("res://Scenes/main_menu.tscn")
var gameScene = preload("res://Scenes/game.tscn")
var editorScene = preload("res://Scenes/edit.tscn")
var pos1 = 0.0
var pos2 = 0.0
var MaxPos
var MinPos = 540
var switchSpeed = 7
var curPos = 0
static var songToPlay
var dir
var noteGUIs: Array
var changingScene = false

func _physics_process(delta):
	$ScrollContainer.scroll_vertical = lerp(float($ScrollContainer.scroll_vertical), float(pos2), switchSpeed * delta)
	noteGUIs[curPos].scale = lerp(Vector2(noteGUIs[curPos].scale), Vector2(1.05,1.05), 0.1)
func _unhandled_key_input(event):
	if(event.is_action_pressed("ui_down")):
		if(curPos >= MaxPos):
			return
		noteGUIs[curPos].scale = Vector2(1,1)
		curPos += 1
		pos2 = curPos * guiOffset
		SetColor(8)
	
	if(event.is_action_pressed("ui_up")):
		if(curPos <= 0):
			return
		noteGUIs[curPos].scale = Vector2(1,1)
		curPos -= 1
		pos2 = curPos * guiOffset
		SetColor(0)
	
	if(event.is_action_pressed("ui_accept")):
		$Transition.play("fade_out")
		await $Transition.animation_finished
		loadSong(0)
	
	if(event.is_action_pressed("ui_cancel")):
		if(changingScene):
			return
		changingScene = true
		$Transition.play("fade_out")
		await $Transition.animation_finished
		var GameInstance = mainMenu.instantiate()
		get_parent().add_child(GameInstance)
		queue_free()

func changeGameScene(sceneIndex):
	$Transition.play("fade_in")
	var editor = false
	match sceneIndex:
		0:
			sceneToUse = gameScene
		1:
			sceneToUse = editorScene
			editor = true
	
	dir = DirAccess.get_directories_at(path)
	if(editor):
		dir.insert(0, "New Map")
	var i = 1
	MaxPos = dir.size() - 1
	$ScrollContainer/VBoxContainer/ColorRect.custom_minimum_size = Vector2(1920, MaxPos * guiOffset + 1080)
	if(MinPos > MaxPos):
		MinPos = MaxPos * guiOffset
	for folder in dir:
		var instance = GUI.instantiate()
		$ScrollContainer/VBoxContainer.add_child(instance)
		instance.initialize(i ,folder.get_basename())
		noteGUIs.append(instance)
		i+=1
	for j in clamp(noteGUIs.size(), 0, 8):
		SetColor(j)

func loadSong(value):
	if(changingScene):
			return
	changingScene = true
	songToPlay = dir[curPos + value]
	var GameInstance = sceneToUse.instantiate()
	GameInstance.path = path + songToPlay
	get_parent().add_child(GameInstance)
	queue_free()

func _input(event):
	if(not event is InputEventMouse || event is InputEventMouseMotion || event.is_released()):
		return
	if(event.button_index == 1):
		if(480 < event.position.x && 960 > event.position.x):
			loadSong(int(event.position.y + 80)/ guiOffset - 1)

func SetColor(i):
	if(i + curPos > dir.size() - 1 || dir[curPos + i] == "New Map"):
		return
	var dataPath = null
	for file in DirAccess.get_files_at(path + str(dir[curPos + i])):
		if(file.ends_with(".json")):
			dataPath = path + dir[curPos + i] + '/' + file
	if(dataPath == null):
		return
	var songData: Dictionary = parseFile(dataPath)
	if(!songData.has("color")):
		noteGUIs[curPos + i].self_modulate = Color(0.556952,1,0.579451,1)
		return
	noteGUIs[curPos + i].self_modulate = str_to_var(songData.color)

func parseFile(_path):
	var file = FileAccess.open(_path, FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	data = JSON.parse_string(data)
	return data
