extends CharacterBody2D

@export var speed = 80    # Higher speed = slower enemy and vice versa
@export var health = 100
@export var knockback_strength = 100
@export var knockback_duration = 0.2
var player_in_attack_range = false
var player_chase = false
var player = null

var knockback_velocity = Vector2.ZERO
var knockback_time = 0.0

func enemy():
	pass

func _physics_process(delta: float) -> void:
	deal_damage()
	
	if knockback_time > 0:
		position += knockback_velocity * delta
		knockback_time -= delta
	else:
		if player_chase:
			position += (player.position - position) / speed
			# Animations to go here

func UpdateHealth():
	var healthBar = $HealthBar
	healthBar.value = health
	
	if health >= 100:
		healthBar.visible = false
	else:
		healthBar.visible = true

func _on_detection_area_body_entered(body: Node2D):
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D):
	player = null
	player_chase = false

func _on_enemy_hitbox_area_body_entered(body: Node2D):
	if body.has_method("player"):
		player_in_attack_range = true
		apply_knockback(body)

func _on_enemy_hitbox_area_body_exited(body: Node2D):
	if body.has_method("player"):
		player_in_attack_range = false
		
func deal_damage():
	if player_in_attack_range and Global.player_current_attack == true:
		health -= 20
		print("enemy health = ", health)
		if health <= 0:
			self.queue_free()

func apply_knockback(body: Node2D):
	var direction = (position - body.position).normalized()
	knockback_velocity = direction * knockback_strength / knockback_duration
	knockback_time = knockback_duration
