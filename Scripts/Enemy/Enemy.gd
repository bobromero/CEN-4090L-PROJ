extends CharacterBody2D

@export var speed = 80    #Higher speed = slower enemy and vice versa
@export var health = 100
var player_in_attack_range = false
var player_chase = false
var player = null 

func enemy():
	pass

func _physics_process(delta: float) -> void:
	deal_damage()
	
	if player_chase:
		position += (player.position - position)/speed
		#Animations to go here

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

func _on_enemy_hitbox_area_body_exited(body: Node2D):
	if body.has_method("player"):
		player_in_attack_range = false
		
func deal_damage():
	if player_in_attack_range and Global.player_current_attack == true:
		health = health - 20
		print("enemy health = ", health)
		if health <= 0:
			self.queue_free()
			
