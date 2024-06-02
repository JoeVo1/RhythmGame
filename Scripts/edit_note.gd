class_name EditNote
extends Area2D

const lanes = [Vector2(-50,135),Vector2(-50,405),Vector2(-50,675),Vector2(-50,945)]
var speed
static var pause : bool = false
static var frozen : bool = false
var beat: int
var xPos
@onready var scoreLabels = [preload("res://Assets/miss.png"), preload("res://Assets/ok.png"), preload("res://Assets/good.png"), preload("res://Assets/perfect.png")]
@onready var accuracy = preload("res://Scripts/noteCollider.gd")
@onready var label = $Label
var letter
var hit = false
var draggable = false
var bodyRef = null
var initLane = null

func initialize(lane, _char, beatsToGoal):
	var distance = position.x - 1708
	speed = abs(distance/beatsToGoal)
	letter = _char
	label.text = letter
	initLane = lane
	position = lanes[lane]

func _physics_process(delta):
	if(pause || frozen):
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
	if(frozen):
		return
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

func changePos(pos):
	position.x = 1708 / 7 * pos
	xPos = position.x

func selectNote(select):
	if(select):
		$Sprite2D.self_modulate = Color(4,4,4,4)
	else:
		$Sprite2D.self_modulate = Color(1,1,1,1)

func changeLabel(text):
	$Label.text = text
	label = text

func _process(delta):
	if(!draggable):
		return
	if(Input.is_action_pressed("click")):
		global_position = get_global_mouse_position()
	elif(Input.is_action_just_released("click")):
		if(bodyRef == null):
			position = Vector2(xPos,lanes[initLane].y)
			return
		else:
			initLane = bodyRef.get_meta("lane")
			position = Vector2(xPos,lanes[initLane].y)
			get_tree().root.get_child(0).allNotes[beat].lane = initLane

func _on_area_entered(area):
	if(area.is_in_group("drag")):
		bodyRef = area

func _on_area_exited(area):
	if(area.is_in_group("drag")):
		bodyRef = null

func _on_select_btn_mouse_entered():
	draggable = true
	scale = Vector2(1.05,1.05)

func _on_select_btn_mouse_exited():
	draggable = false
	scale = Vector2(1,1)


func _on_select_btn_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				get_tree().root.get_child(0).selectNote(beat, true)
			MOUSE_BUTTON_RIGHT:
				get_tree().root.get_child(0).RemoveNote(beat, false)
	
