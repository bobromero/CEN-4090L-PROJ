extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func Return_Menu():
	Global.playerScore=0
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func Player_dead():
	get_tree().change_scene_to_file("res://Scenes/DeadScreen.tscn")
	pass 
	
func Enter_level(level: int) -> void:
	if level == 1:
		get_tree().change_scene_to_file("res://Dungeon/StartingRoom.tscn")
	else:
		pass

func Pause():
	get_tree().change_scene_to_file("res://Scenes/PauseMenu.tscn")
	pass
