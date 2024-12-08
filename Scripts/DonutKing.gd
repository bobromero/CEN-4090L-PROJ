extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@onready var _animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	
	_animated_sprite.play("default")



@export var speed = 80    # Higher speed = slower enemy and vice versa
@export var health = 100

var player_in_attack_range = false
var player_chase = false
var player = null

func enemy():
	pass

func _physics_process(delta: float) -> void:
	#velocity.y = gravity
	position += (player.position - position) / speed
	
	UpdateHealth()
	move_and_slide()
	deal_damage()

func UpdateHealth():
	var healthBar = $HealthBar
	healthBar.value = health

	if health >= 100:
		healthBar.visible = false
	else:
		healthBar.visible = true

func deal_damage():
	if player_in_attack_range and Global.player_current_attack == true:
		health = health - 20
		health -= 50
		print("enemy health = ", health)
		if health <= 0:
			Global.playerScore +=100
			self.queue_free()




func _on_hitbox_body_entered(body: Node2D) -> void:
	print("hitbox body entered")
	if body.has_method("player"):
		pass
	if body.is_in_group("projectiles"):  # added functionality for when an enemy is hit by a projectile.
		health -= 50
		if health <= 0:
			self.queue_free()
			Global.playerScore +=1000
		
