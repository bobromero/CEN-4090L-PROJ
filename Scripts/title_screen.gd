extends Control

@onready var button = $Button
@onready var video_player = $VideoStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	video_player.show()
	video_player.stop()  # Reset the video
	video_player.play()
	
	if button.pressed.is_connected(_on_button_pressed):
		button.pressed.disconnect(_on_button_pressed)
	
	button.pressed.connect(_on_button_pressed)
	print("Button signal connected")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	
	video_player.stop()
	SceneManager.Enter_level(1) #calls the scene manager script to change the game to level 1
	#get_tree().change_scene_to_file("res://Scenes/GameplayLoopTest.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()
