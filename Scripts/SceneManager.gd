extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func Return_Menu():
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func Player_dead():
	get_tree().change_scene_to_file("res://Scenes/DeadScreen.tscn")
	pass 
