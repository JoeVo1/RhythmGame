extends Node2D
 
@onready
var spectrum = AudioServer.get_bus_effect_instance(3,0)
 
@onready
var swatches = $Swatches.get_children()
 
const VU_COUNT = 64
const HEIGHT = 1000
const FREQ_MAX = 11050.0
 
const MIN_DB = 70
var volume = 0.0

func _ready():
	var i = 0
	for swatch in swatches:
		swatch.self_modulate = Color(i,i,i)
		i +=0.015625

func _process(delta):
	if(!$AudioStreamPlayer.playing):
		return
	var prev_hz = 0
	for i in range(1,VU_COUNT+1):   
		var hz = i * FREQ_MAX / VU_COUNT;
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz)
		var energy = clamp((MIN_DB + linear_to_db(f.length()))/MIN_DB,0,1)
		var height = energy * HEIGHT
 
		prev_hz = hz
 
		var bottomRightRect = swatches[i - 1]
 
		var tween = get_tree().create_tween()
 
		tween.tween_property(bottomRightRect, "size", Vector2(bottomRightRect.size.x, height), 0.05)
 

func playSong(songPath):
	var song = null
	songPath = "user://Songs/" + songPath
	for file in DirAccess.get_files_at(songPath):
		if(file.ends_with(".ogg")):
			song = file
	if(song == null):
		get_parent().PlayMusic()
		return
	$AudioStreamPlayer.stream = AudioStreamOggVorbis.load_from_file(songPath + '/' + song)
	$AudioStreamPlayer.play()


func _on_audio_stream_player_finished():
	get_parent().PlayMusic()
