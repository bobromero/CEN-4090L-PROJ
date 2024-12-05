extends CharacterBody2D

const JUMP = 40

@export var speed = 80    # Higher speed = slower enemy and vice versa
@export var health = 100
@export var knockback_strength = 500
@export var knockback_duration = 0.2
@export var gravity = 500.0
@export var knockback_enabled = false
@export var knockback_timer = 0.0  

var player_in_attack_range = false
var player_chase = false
var player = null

func enemy():
	pass

func _physics_process(delta: float) -> void:
	#velocity.y = gravity
	
	if knockback_enabled:
		apply_knockback(delta)
	elif player_chase:
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
		health -= 20
		print("enemy health = ", health)
		if health <= 0:
			Global.playerScore +=100
			self.queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
func apply_knockback_to_enemy():
	if not knockback_enabled and player != null:
		var knockback_direction = (position - player.position).normalized()
		velocity = knockback_direction * knockback_strength
		knockback_enabled = true
		knockback_timer = knockback_duration

func apply_knockback(delta: float) -> void:
	# Reduce the knockback timer
	knockback_timer -= delta
	if knockback_timer <= 0:
		knockback_enabled = false
		velocity = Vector2.ZERO


func _on_hitbox_body_entered(body: Node2D) -> void:
	print("hitbox body entered")
	if body.has_method("player"):
		apply_knockback_to_enemy()
	if body.is_in_group("projectiles"):  # added functionality for when an enemy is hit by a projectile.
		health -= 50
		if health <= 0:
			self.queue_free()
			Global.playerScore +=100
		apply_knockback_to_enemy()
