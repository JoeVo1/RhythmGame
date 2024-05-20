extends Sprite2D
var beat
var lane := 0
var label := "a"

func changeLabel(text):
	$Label.text = text
	label = text

func selectNote(select):
	if(select):
		self_modulate = Color(4,4,4,4)
	else:
		self_modulate = Color(1,1,1,1)
