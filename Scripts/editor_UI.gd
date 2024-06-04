extends Node
var editor

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().files_dropped.connect(on_file_dropped)
	editor = get_parent()

func _on_cancel_btn_button_down():
	$Panel.visible = false

func _on_back_btn_button_down():
	if(editor.saved):
		get_tree().current_scene = editor
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		$SaveAndExit.visible = true
		$Panel.visible = false

func _on_color_picker_color_changed(color):
	editor.SelectorColor = color

func _on_save_btn_button_down():
	editor.writeFile()

func _on_approach_rate_value_changed(value):
	editor.approachRate = value

func _on_delay_value_changed(value):
	editor.delay = value
	loadSong()

func _on_bpm_value_changed(value):
	editor.bpm = value
	loadSong()

func _on_file_btn_button_down():
	$FileDialog.current_dir = "/Users"
	$FileDialog.visible = !$FileDialog.visible
	editor.maxBeats = editor.conductor.song_length_in_beats

func on_file_dropped(file):
	if(file.size() != 1):
		editor.SendError("only 1")
		return
	if(!file[0].ends_with(".ogg")):
		editor.SendError("incorrect File Type")
		return
	editor.songPath = file[0]
	loadSong()
	$ScrollContainer/HBoxContainer/ColorRect.size.x = (editor.conductor.song_length_in_beats * editor.offset) + 2400
	editor.maxBeats = editor.conductor.song_length_in_beats
	$FileBtn.text = file[0].get_file()

func _on_file_dialog_file_selected(_path):
	editor.songPath = _path
	$FileBtn.text = _path.get_file()
	loadSong()
	$ScrollContainer/HBoxContainer/ColorRect.size.x = (editor.conductor.song_length_in_beats * editor.offset) + 2400
	editor.maxBeats = editor.conductor.song_length_in_beats

func loadSong():
	editor.conductor.loadSong(editor.songPath,editor.bpm,editor.delay)
	editor.conductor.stream_paused = true

func _on_color_picker_btn_button_down():
	$ColorPicker.visible = !$ColorPicker.visible


func _on_error_button_down():
	$Error.visible = false


func _on_save_and_exit_btn_button_down():
	if(editor.writeFile() == true):
		get_tree().current_scene = editor
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		$SaveAndExit.visible = false


func _on_exit_btn_button_down():
	get_tree().current_scene = editor
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_SAEcancel_btn_button_down():
	$SaveAndExit.visible = false
