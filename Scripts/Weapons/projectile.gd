extends CharacterBody2D

@export var SPEED = 1000

var direction : float
var initialPos : Vector2
var initialRot : float
var zAxis : int

func _ready(): 
	global_position = initialPos
	global_rotation = initialRot
	z_index = zAxis
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -SPEED).rotated(direction)
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("hit")
	queue_free()
