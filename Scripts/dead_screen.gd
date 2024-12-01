extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update_score(new_score: int) -> void:
	$scoreCount.text = "Score: " + str(new_score)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_score(Global.playerScore)
	pass


func _on_menu_pressed() -> void:
	SceneManager.Return_Menu()
	pass 
