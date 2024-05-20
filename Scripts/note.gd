extends Area2D

const lane1 = Vector2(-50,135)
const lane2 = Vector2(-50,405)
const lane3 = Vector2(-50,675)
const lane4 = Vector2(-50,945)
var speed
@onready var scoreLabels = [preload("res://Assets/miss.png"), preload("res://Assets/ok.png"), preload("res://Assets/good.png"), preload("res://Assets/perfect.png")]
@onready var accuracy = preload("res://Scripts/noteCollider.gd")
@onready var label = $Label
var letter
var hit = false

func initialize(lane, _char, beatsToGoal):
	var distance = position.x - 1708
	speed = abs(distance/beatsToGoal)
	letter = _char
	label.text = letter
	match lane:
		0:
			position = lane1
		1:
			position = lane2
		2:
			position = lane3
		3:
			position = lane4

func _physics_process(delta):
	if hit:
		var scale = lerp($Score.scale.x, 0.1, 0.1)
		$Score.scale = Vector2(scale, scale)
		return
	position += Vector2(speed * delta, 0)
	if(position.x > 2000):
		accuracy.combo = 0
		accuracy.notesHit += 1
		get_parent().updateScore()
		queue_free()

func destroy(score):
	hit = true
	$CollisionShape2D.disabled = true
	position = Vector2(1708, position.y)
	$Timer.start()
	$Sprite2D.visible = false
	label.visible = false
	$CPUParticles2D.emitting = true
	$Score.texture = scoreLabels[score]

func _on_timer_timeout():
	queue_free()
