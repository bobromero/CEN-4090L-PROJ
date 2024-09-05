extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var _isPlatformer: bool = false


func _physics_process(delta: float) -> void:
	if _isPlatformer:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		_platformerMovement(delta)	
	
	else:
		_topDownMovement()

	move_and_slide()

func _topDownMovement():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

func _platformerMovement(delta: float):
	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
