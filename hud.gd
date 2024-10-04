extends CanvasLayer


class_name playerHud

#@export var currentscore = 0
#
##function to add 10 to the score
#func addScore(int) -> void:
	#currentscore += int
	#
#func rmScore(int) -> void:
	#currentscore -= int
	
func update_score(new_score: int) -> void:
	$scoreCount.text = "Score: " + str(new_score)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
