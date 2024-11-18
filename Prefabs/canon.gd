extends Node2D

@onready var ProjectileShooter = get_tree().get_root().get_node("ProjectileShooter")
@onready var projectile = load("res://Scenes/Projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shoot()
	pass # Replace with function body.

func shoot():
	var instance = projectile.instantiate()
	instance.direction = rotation
	instance.initialPos = global_position
	instance.initialRot = rotation
	ProjectileShooter.add_child.call_deferred(instance)
	instance.zAxis = z_index-1
	
