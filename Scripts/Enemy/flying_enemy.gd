extends "res://Scripts/Enemy/enemy.gd"


@export var flying_speed = 200 

func _physics_process(delta: float) -> void:
	# Override the basic enemy movement to include flying logic
	if knockback_enabled:
		apply_knockback(delta)
	elif player_chase and player != null:
		# Move towards the player in both X and Y directions (flying)
		var direction = (player.position - position).normalized()
		position += direction * flying_speed * delta
	
	UpdateHealth()
	move_and_slide()  
	deal_damage()

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
