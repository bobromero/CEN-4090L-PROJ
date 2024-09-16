extends CanvasLayer

var currentscore = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$scoreCount.text = "Score: " + str(currentscore) + "00"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
