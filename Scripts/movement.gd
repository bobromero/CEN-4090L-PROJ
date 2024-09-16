extends Resource

class_name movement


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
@export var _isPlatformer: bool = false
var player:CharacterBody2D

func SetPlayer(_player: CharacterBody2D):
	player = _player
	print("here")


@onready var coyote_time = $CoyoteTimer 
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_height_timer = $JumpHeightTimer

var can_coyote_jump = false
var jump_buffered = false


func _physics_process(delta: float) -> void:
	if _isPlatformer:
		_platformerMovement(delta)
	
	else:
		_topDownMovement()


func _topDownMovement():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		player.velocity = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.y = move_toward(player.velocity.y, 0, SPEED)

	move_and_slide()



func _platformerMovement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > 1000:
			velocity.y = 1000
	# Handle jump.
	if Input.is_action_just_pressed("up") and player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY
	
	# Handle jump.
	if Input.is_action_just_pressed("up"):
		jump_height_timer.start()
		jump()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	#Play starts falling
	if was_on_floor and !is_on_floor() and velocity.y >= 0:
		can_coyote_jump = true
		coyote_time.start()
		
	#Player has tounched ground
	if !was_on_floor and is_on_floor():
		if jump_buffered:
			jump_buffered = false
			print("Buffered jump")
			jump()

func jump():
	if is_on_floor() || can_coyote_jump:
		#Gives you a grace period to jump off the edge of a platform
		velocity.y = JUMP_VELOCITY
		if can_coyote_jump:
			can_coyote_jump = false
			print("Coyote jump")
	else:
		if !jump_buffered:
			jump_buffered = true
			jump_buffer_timer.start()
			
			
func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false

func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("up"):
		if velocity.y < -90:
			velocity.y = -90
	else:
		pass
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
