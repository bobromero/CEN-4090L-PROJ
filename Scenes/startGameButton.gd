extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	# Load the new scene (e.g., "GameScene.tscn")
	var new_scene = load("res://Scenes/MovementTest.tscn")
	# Change the current scene to the new scene
	get_tree().change_scene_to(new_scene)
	pass # Replace with function body.
