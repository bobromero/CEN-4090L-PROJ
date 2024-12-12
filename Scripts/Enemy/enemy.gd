extends CharacterBody2D

@export var speed = 150    # Higher speed = slower enemy and vice versa
@export var health = 100
@export var knockback_strength = 500
@export var knockback_duration = 0.2
@export var knockback_enabled = false
@export var knockback_timer = 1.0 

@onready var anim = $AnimatedSprite2D

var player_in_attack_range = false
var player_chase = false
var player = null
var knockback_velocity = Vector2.ZERO
var player_cooldown = true

func _ready() -> void:
	add_to_group("Enemy")

func enemy():
	pass

func _physics_process(delta: float) -> void:
	if knockback_enabled:
		print("knockback")
		apply_knockback(delta)
	elif player_chase:
		velocity = (player.position - position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	if velocity != Vector2.ZERO:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				anim.flip_h = false
			if velocity.x < 0:
				anim.flip_h = true
			anim.play("Run")
		else:
			if velocity.y > 0:
				anim.play("Run_down")
			else:
				anim.play("Run_up")
	else:
		anim.play("Idle")
				
	UpdateHealth()
	move_and_slide()

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
		health -= 20
		print("enemy health = ", health)
		if health <= 0:
			Global.playerScore +=100
			self.queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = null
		player_chase = false

func apply_knockback_to_enemy():
	if not knockback_enabled and player != null:
		var knockback_direction = (position - player.position).normalized()
		knockback_velocity = knockback_direction * knockback_strength
		knockback_enabled = true
		knockback_timer = knockback_duration

func apply_knockback(delta: float) -> void:
	# Apply knockback velocity
	velocity = knockback_velocity
	# Reduce the knockback timer
	knockback_timer -= delta
	if knockback_timer <= 0:
		knockback_enabled = false
		knockback_velocity = Vector2.ZERO  # Reset knockback velocity after knockback ends
		print("Knockbacked")

func _on_hitbox_body_entered(body: Node2D) -> void:
	#print("hitbox body entered")
	if body.has_method("player"):
		player_in_attack_range = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_range = false

func _on_damage_cooldown_timeout():
	player_cooldown = true
	#if body.is_in_group("projectiles"):  # added functionality for when an enemy is hit by a projectile.
	#	health -= 50
	#	if health <= 0:
	#		self.queue_free()
	#		Global.playerScore +=100
	#	apply_knockback_to_enemy()
