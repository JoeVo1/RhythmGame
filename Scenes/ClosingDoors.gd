extends Node2D

@export var topDestination: float
@export var bottemDestination: float
var closing = false

func _physics_process(delta):
	if(!closing):
		return
	$Top.position.y = lerpf($Top.position.y, topDestination, 0.05)
	$Bottem.position.y = lerpf($Bottem.position.y, bottemDestination, 0.05)

func closeDoors():
	closing = true
	$DoorTimer.start()

func _on_door_timer_timeout():
	$Panel/Score/Label.text += str(Collider.TotalScore)
	$Panel/Misses/Label.text += str(Collider.misses)
	$Panel/Okay/Label.text += str(Collider.okayScore)
	$Panel/Good/Label.text += str(Collider.goodScore)
	$Panel/Perfect/Label.text += str(Collider.perfectScore)
	$Panel.visible = true
