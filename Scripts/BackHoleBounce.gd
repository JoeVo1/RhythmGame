extends Node
var blackHole = preload("res://Prefabs/BlackHole.tscn")
var Instance = null
var target : Vector2
var speed


func _ready():
	await waitRandom()
	initiateBlackHole()


func _physics_process(delta):
	if(Instance == null):
		return
	if(Instance.position == target):
		Instance = null
		await waitRandom()
		initiateBlackHole()
	Instance.position = Instance.position.move_toward(target, speed)
	Instance.rotate(0.02)

func initiateBlackHole():
	if(Instance != null):
		Instance.queue_free()
	speed = randf_range(5, 15)
	Instance = blackHole.instantiate()
	get_parent().call_deferred("add_child", Instance)
	var direction = randi() % 2
	var multiplier = 1
	if(direction):
		multiplier = -1
	if randi() % 2:
		target = Vector2(2120, randf_range(-30, 1080 * multiplier))
		Instance.position = Vector2(-200,randf_range(-30, 180 * multiplier))
	else:
		target = Vector2(randf_range(-30, 1110 * multiplier), 1280)
		Instance.position = Vector2(randf_range(-30, 1110 * multiplier), -200)

func waitRandom():
	await get_tree().create_timer(randf_range(30, 60)).timeout
