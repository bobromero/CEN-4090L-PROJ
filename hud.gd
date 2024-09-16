extends CanvasLayer


@export var currentscore = 0

#function to add 10 to the score
func addScore(int) -> void:
	currentscore += int
	
func rmScore(int) -> void:
	currentscore -= int
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$scoreCount.text = "Score: " + str(currentscore)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
