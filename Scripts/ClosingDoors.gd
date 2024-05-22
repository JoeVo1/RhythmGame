extends Node2D

func closeDoors():
	$DoorAni.play("DoorAni")
	$Panel/Score/Label.text += str(Collider.TotalScore)
	$Panel/Misses/Label.text += str(Collider.misses)
	$Panel/Okay/Label.text += str(Collider.okayScore)
	$Panel/Good/Label.text += str(Collider.goodScore)
	$Panel/Perfect/Label.text += str(Collider.perfectScore)
