extends Node2D

func _ready():
	$AnimationPlayer.play("RESET")


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("pause_animation")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("pause_animation")

func PauseTest():
	if Input.is_action_just_pressed("escape") and get_tree().paused==false:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused==true:
		resume()
			

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	PauseTest()
	pass


func _on_resume_pressed() -> void:
	resume()
	pass # Replace with function body.


func _on_restart_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://Scenes/DungeonTest.tscn")
	resetDungeon()
	pass # Replace with function body.


func _on_return_menu_pressed() -> void:
	resume()
	SceneManager.Return_Menu()
	resetDungeon()
	pass # Replace with function body.

func resetDungeon():
	var MyCSharpScript = load("res://Dungeon/Dungen.cs")
	var myNode = MyCSharpScript.new()
	myNode.call("DeleteDungeon")
