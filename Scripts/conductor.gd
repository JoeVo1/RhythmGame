extends AudioStreamPlayer

@export var bpm := 100
@export var measures := 4


# Tracking the beat and song position
var song_position = 0.0
var song_length = 0.0
var song_length_in_beats = 0
var song_position_in_beats = 0
var sec_per_beat = 60.0 / bpm
var last_reported_beat = 0
var beats_before_start = 0
var measure = 1
var delay

# Determining how close to the beat an event is
var closest = 0
var time_off_beat = 0.0

signal beat(position)
signal measureSignal(position)
signal songFinished()

func loadSong(path, _bpm, _delay):
	if(path == null):
		return
	bpm = _bpm
	sec_per_beat = 60.0 / bpm
	stream = AudioStreamOggVorbis.load_from_file(path)
	song_length = stream.get_length()
	song_length_in_beats = int(floor(song_length / sec_per_beat))
	delay = _delay / 1000
	play()

func _physics_process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency() + delay
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		_report_beat()


func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if measure > measures:
			measure = 1
		emit_signal("beat", song_position_in_beats)
		emit_signal("measureSignal", measure)
		last_reported_beat = song_position_in_beats
		measure += 1

func closest_beat(nth):
	closest = int(round((song_position / sec_per_beat) / nth) * nth) 
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)


func play_from_beat(beat):
	last_reported_beat = beat
	play()
	seek(beat * sec_per_beat)
	measure = beat % measures
