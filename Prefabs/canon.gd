extends Node2D

@onready var ProjectileShooter = get_parent()
@onready var projectile = preload("res://Scenes/Projectile.tscn")

var onCooldown = false
var cooldownTime = 0.2 # sets the cooldown time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("shoot") and onCooldown == false: #shoots when spacebar is hit
		shoot()
		cooldown()
	pass



func shoot():
	var instance = projectile.instantiate()
	
	var direction = Vector2.ZERO #for some reason these are inverted but it works.
	if Input.is_action_pressed("right"):
		direction.y +=1
	if Input.is_action_pressed("left"):
		direction.y -=1
	if Input.is_action_pressed("up"):
		direction.x +=1
	if Input.is_action_pressed("down"):
		direction.x -=1

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
	
