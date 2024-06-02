extends AudioStreamPlayer

var selection = preload("res://Assets/Audio/Menu Selection Click.wav")
var hitSound = preload("res://Assets/Audio/osuHit.wav")
var missSound = preload("res://Assets/Audio/combobreak.wav")
var SongSelect = preload("res://Assets/Audio/click_2.wav")

func _process(delta):
	pass

func hover():
	stream = selection
	play()

func PlayHitSound(hit):
	if(hit):
		stream = hitSound
	elif(!hit):
		stream = missSound
	else:
		return
	play()

func SongSelectSound():
	stream = SongSelect
	play()
