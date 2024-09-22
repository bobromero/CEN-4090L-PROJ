extends CharacterBody2D

class_name enemySprite

var speed = 100
var player_chase = false
var player = null

func _physics_process(delta):
	if player_chase:
		position += (player.position - position)
		#Animations will go here
