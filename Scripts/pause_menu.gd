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
func _process(delta: float) -> void:
	PauseTest()
	pass


func _on_resume_pressed() -> void:
	resume()
	pass # Replace with function body.


func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	
	pass # Replace with function body.


func _on_return_menu_pressed() -> void:
	resume()
	SceneManager.Return_Menu()
	pass # Replace with function body.
