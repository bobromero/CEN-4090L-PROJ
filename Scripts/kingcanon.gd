extends Node2D

@onready var King = get_parent()
@onready var projectile = preload("res://Scenes/DonutProjectile.tscn")

var onCooldown = false
var cooldownTime = 1 # sets the cooldown time
var rotation_angle = 25  #for near death mode.
var superMode = false # flag to control the mode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:	#each second it shoots 8 donuts, with the directions rotating 
	var direction = Vector2.ZERO
	
	print(str(King.health))
	
	if King.health <= 100:
		superMode = true
	if superMode == true: #makes it alot harder when the king is low on health
		cooldownTime = 0.3
	if onCooldown == false: #shoots and rotates to make it harder
				#Create the 8 directions for shooting the donutes
				var directions = []
				for i in range(8):
					var angle = (i * PI/4) + rotation_angle #Calculate the angle for each direction
					direction = Vector2(cos(angle), sin(angle))
					shoot(direction)
				
				rotation_angle += PI/16
				rotation_angle = fmod(rotation_angle, PI * 2)
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
	
