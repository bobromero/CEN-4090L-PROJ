extends CharacterBody2D

class_name Enemy


@export var speed = 150    # Higher speed = slower enemy and vice versa
var health
@export var MaxHealth = 200
@export var knockback_strength = 500
@export var knockback_duration = 0.2
@export var knockback_enabled = false
@export var knockback_timer = 1.0 

@onready var coin = preload("res://Prefabs/Coin.tscn")

var player_in_attack_range = false
var player_chase = false
var player : CharacterBody2D = null
var knockback_velocity = Vector2.ZERO
var player_cooldown = true

func _ready() -> void:
	health = MaxHealth
	var healthBar:ProgressBar = $HealthBar
	healthBar.max_value = MaxHealth

func _physics_process(delta: float) -> void:
	if knockback_enabled:
		#print("knockback")
		apply_knockback(delta)
	elif player_chase:
		velocity = (player.global_position - global_position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	UpdateHealth()
	move_and_slide()

func UpdateHealth():
	var healthBar = $HealthBar
	healthBar.value = health

	if health >= MaxHealth:
		healthBar.visible = false
	else:
		healthBar.visible = true
		
	if health <= 0:
		SpawnCoin()
		self.queue_free()
			
func SpawnCoin():
	var instance :Node2D = coin.instantiate()
	instance.global_position = global_position;
	instance.scale = Vector2(.25,.25)
	get_tree().current_scene.add_child(instance)


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
		#print("Knockbacked")

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("hitbox body entered")
	if body.is_in_group("Player"):
		print("is player")
		body.call("enemy_attack")
		player_in_attack_range = true

func TakeDamage(amount : int):
	health -= amount;

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = false

func _on_damage_cooldown_timeout():
	player_cooldown = true
	#if body.is_in_group("projectiles"):  # added functionality for when an enemy is hit by a projectile.
	#	health -= 50
	#	if health <= 0:
	#		self.queue_free()
	#		Global.playerScore +=100
	apply_knockback_to_enemy()
