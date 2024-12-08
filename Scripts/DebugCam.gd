extends CharacterBody2D

@export var speed = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("down"):
		movement += Vector2(0,speed)
	if Input.is_action_pressed("up"):
		movement += Vector2(0,-speed)
	if Input.is_action_pressed("left"):
		movement += Vector2(-speed,0)
	if Input.is_action_pressed("right"):
		movement += Vector2(speed,0)
	movement = movement.normalized()
	velocity = movement * 1000
	move_and_slide()
