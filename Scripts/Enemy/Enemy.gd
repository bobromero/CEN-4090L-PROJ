extends CharacterBody2D

@export var speed = 65 
var player_chase = false
var player = null 


func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position)/speed
		#Animations to go here


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
