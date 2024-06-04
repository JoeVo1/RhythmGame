class_name note_
extends Area2D

const lanes = [Vector2(-50,135),Vector2(-50,405),Vector2(-50,675),Vector2(-50,945)]
var speed
static var pause : bool = false
@onready var scoreLabels = [preload("res://Assets/miss.png"), preload("res://Assets/ok.png"), preload("res://Assets/good.png"), preload("res://Assets/perfect.png")]
@onready var accuracy = preload("res://Scripts/noteCollider.gd")
@onready var label = $Label
var letter
var hit = false

func initialize(lane, _char, beatsToGoal):
	$CPUParticles2D.visible = SaveSettings.enableParticles
	var distance = position.x - 1708
	speed = abs(distance/beatsToGoal)
	letter = _char
	label.text = letter
	position = lanes[lane]

func _physics_process(delta):
	if(pause):
		return
	if hit:
		var scale = lerp($Score.scale.x, 0.1, 0.1)
		$Score.scale = Vector2(scale, scale)
		return
	position += Vector2(speed * delta, 0)
	if(position.x > 2000):
		accuracy.combo = 0
		accuracy.notesHit += 1
		get_parent().get_parent().updateScore()
		queue_free()

func destroy(score):
	if(hit):
		return
	hit = true
	$CollisionShape2D.disabled = true
	position = Vector2(1708, position.y)
	$Timer.start()
	$Sprite2D.visible = false
	label.visible = false
	if(score > 0):
		$CPUParticles2D.amount *= score
		$CPUParticles2D.emitting = true
	$Score.texture = scoreLabels[score]

func _on_timer_timeout():
	queue_free()
