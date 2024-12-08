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
	var timer = get_tree().create_timer(5.0) #deletes all projectiles after 5 seconds
	timer.timeout.connect(queue_free)
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -SPEED).rotated(direction)
	var collision = move_and_collide(velocity * delta)

	if collision:  # Check if we collided with the player
		var collider = collision.get_collider()
		if collider.is_in_group("Player"):
			await get_tree().create_timer(0.05).timeout #allows for hit processing on enemy script before the fireball deletes itself.
			queue_free()  # Delete the projectile immediately on collision
		if collider.is_in_group("hitable"):
			await get_tree().create_timer(0.05).timeout #allows for hit processing on enemy script before the fireball deletes itself.
			queue_free()  # Delete the proj
