extends Resource 

class_name movement


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var _sprint_multiplier = 1.2
@export var _isPlatformer: bool = false

var player:CharacterBody2D
var anim


func SetPlayer(_player: CharacterBody2D):
	player = _player
	anim = player.get_node("AnimatedSprite2D")
	print("here")


var coyote_timer = 0.15 #Time in seconds
var jump_buffer_timer = 0.15
var jump_height_timer = 0.10

var can_coyote_jump = false
var jump_buffered = false
var jump_height_timer_on = false


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
		if Input.is_action_pressed("Sprint"):
			player.velocity *= _sprint_multiplier
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.y = move_toward(player.velocity.y, 0, SPEED)
		anim.play("idle")
		
		
	player.move_and_slide()


func _platformerMovement(delta: float):
	#Checks if any of the three timers are currently running
	if jump_buffered:
		_jump_buffer_timer(delta)
		
	if can_coyote_jump:
		_coyote_timer(delta)
		
	if jump_height_timer_on:
		_jump_height_timer(delta)
		
	# Add the gravity.
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		if player.velocity.y > 1000:
			player.velocity.y = 1000
	
	# Handle jump.
	if Input.is_action_just_pressed("up"):
		jump_height_timer_on = true
		_jump_height_timer(delta)
		jump()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		
	var was_on_floor = player.is_on_floor()
	player.move_and_slide()
	
	#Play starts falling
	if was_on_floor and !player.is_on_floor() and player.velocity.y >= 0:
		can_coyote_jump = true
		
	#Player has tounched ground
	if !was_on_floor and player.is_on_floor():
		if jump_buffered:
			jump_buffered = false
			print("Buffered jump")
			jump()

#Handles jumping
func jump():
	if player.is_on_floor() || can_coyote_jump:
		#Gives you a grace period to jump off the edge of a platform
		player.velocity.y = JUMP_VELOCITY
		if can_coyote_jump:
			can_coyote_jump = false
			print("Coyote jump")
	else:
		if !jump_buffered:
			jump_buffered = true
			
			
#Functions to handle the countdown of the three timers
func _coyote_timer(delta) -> void:
	coyote_timer -= delta
	if coyote_timer <= 0:
		_on_coyote_timer_timeout()
		
func _jump_buffer_timer(delta) -> void:
	jump_buffer_timer -= delta
	if jump_buffer_timer <= 0:
		_on_jump_buffer_timer_timeout()

func _jump_height_timer(delta) -> void:
	jump_height_timer -= delta
	if jump_height_timer <= 0:
		_on_jump_height_timer_timeout()

#Functions deal with what happens when the timers timeout
func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false
	coyote_timer = 0.15

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false
	jump_buffer_timer = 0.15

func _on_jump_height_timer_timeout() -> void:
	print("Jump height timeout")
	if !Input.is_action_pressed("up"):
		if player.velocity.y < -150:
			player.velocity.y = -150
	else:
		pass
		
	jump_height_timer_on = false
	jump_height_timer = 0.10
