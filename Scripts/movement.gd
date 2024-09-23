extends Resource

class_name movement


const SPEED = 450.0
const JUMP_VELOCITY = -400.0
@export var _isPlatformer: bool = false
var player:CharacterBody2D

func SetPlayer(_player: CharacterBody2D):
	player = _player
	print("here")


func _physics_process(delta: float) -> void:
	if _isPlatformer:
		# Add the gravity.
		if not player.is_on_floor():
			player.velocity += player.get_gravity() * delta
			
		_platformerMovement(delta)	
	
	else:
		_topDownMovement()

	player.move_and_slide()

func _topDownMovement():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		player.velocity = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.y = move_toward(player.velocity.y, 0, SPEED)

func _platformerMovement(delta: float):
	# Handle jump.
	if Input.is_action_just_pressed("up") and player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		
