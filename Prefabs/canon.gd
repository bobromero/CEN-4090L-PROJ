extends Node2D

@onready var ProjectileShooter = get_parent()
@onready var projectile = preload("res://Scenes/Projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("shoot"): #shoots when spacebar is hit
		shoot()
	pass



func shoot():
	var instance = projectile.instantiate()
	instance.direction = rotation
	instance.initialPos = global_position
	instance.initialRot = rotation
	ProjectileShooter.add_child.call_deferred(instance)
	instance.zAxis = z_index-1
	
