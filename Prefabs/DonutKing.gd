extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@onready var _animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	
	_animated_sprite.play("default")
