extends Node2D

@onready var ProjectileShooter = get_parent()
@onready var projectile = preload("res://Scenes/Projectile.tscn")

var onCooldown = false
var cooldownTime = 0.4 # sets the cooldown time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:	
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("Rightarrow"):
		direction.y +=1
	if Input.is_action_pressed("Leftarrow"):
		direction.y -=1
	if Input.is_action_pressed("Uparrow"):
		direction.x +=1
	if Input.is_action_pressed("Downarrow"):
		direction.x -=1
	if onCooldown == false and direction != Vector2.ZERO:
		shoot(direction)
		cooldown()




func shoot(direction):
	var instance = projectile.instantiate()
	

	if direction == Vector2.ZERO:
		direction = Vector2.DOWN #shoots right by default
	else:
		direction = direction.normalized() # make sure diagonal shots are the same speed
	
	instance.direction = direction.angle()
	instance.initialPos = global_position
	instance.initialRot = direction.angle()
	instance.zAxis = z_index-1
	
	get_tree().current_scene.add_child(instance)
	
	
func cooldown():
	onCooldown=true
	await get_tree().create_timer(cooldownTime).timeout
	onCooldown=false
	
