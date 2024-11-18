extends CharacterBody2D

@export var SPEED = 100

var direction : float

var initialPos : Vector2

var initialRot : float

func _ready(): 
	global_position = initialPos
	global_rotation = initialRot
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -SPEED).rotated(direction)
	move_and_slide()
