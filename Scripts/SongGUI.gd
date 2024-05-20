extends Sprite2D

const spriteoffset = 140

func initialize(pos,label):
	position = Vector2(960 , pos * spriteoffset)
	$Label.text = label
