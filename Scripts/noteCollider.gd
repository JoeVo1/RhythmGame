extends Node2D

var miss
var okay
var good
var perfect
var currentNote = []
static var TotalScore = 0
static var notesHit = 0
static var combo = 0

func _unhandled_key_input(event):
	if(currentNote.is_empty() || !event.is_pressed()):
		return
	if(event.as_text().to_lower() == currentNote[0].letter.to_lower()):
		match true:
			perfect:
				combo +=1
				TotalScore += 100
				currentNote[0].destroy(3)
			good:
				combo +=1
				TotalScore += 50
				currentNote[0].destroy(2)
			okay:
				combo +=1
				TotalScore += 20
				currentNote[0].destroy(1)
			miss:
				combo = 0
				currentNote[0].destroy(0)
		notesHit += 1
		get_parent().get_parent().updateScore()

func _on_okay_area_area_entered(area):
	if(area.is_in_group("note")):
		okay = true


func _on_okay_area_area_exited(area):
	if(area.is_in_group("note")):
		okay = false


func _on_good_area_area_entered(area):
	if(area.is_in_group("note")):
		good = true


func _on_good_area_area_exited(area):
	if(area.is_in_group("note")):
		good = false


func _on_perfect_area_area_entered(area):
	if(area.is_in_group("note")):
		perfect = true


func _on_perfect_area_area_exited(area):
	if(area.is_in_group("note")):
		perfect = false


func _on_miss_area_area_entered(area):
	if(area.is_in_group("note")):
		miss = true
		currentNote.append(area)


func _on_miss_area_area_exited(area):
	if(area.is_in_group("note")):
		miss = false
		currentNote.remove_at(0)
