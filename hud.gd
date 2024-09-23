extends CanvasLayer


class_name playerHud

@export var currentscore = 0

#function to add 10 to the score
func addScore(int) -> void:
	currentscore += int
	
func rmScore(int) -> void:
	currentscore -= int
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$scoreCount.text = "Score: " + str(currentscore)
