extends AudioStreamPlayer

var selection = preload("res://Assets/Menu Selection Click.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hover():
	stream = selection
	play()
