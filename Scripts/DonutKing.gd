extends CharacterBody2D


@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 80    # Higher speed = slower enemy and vice versa
@export var health = 500

var superMode =false
var player_in_attack_range = false
var player_chase = false
var player = null
var direction = Vector2.RIGHT  # Initial movement direction
var movement_timer = 0
var time_to_change_direction = 2.0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	_animated_sprite.play("default")
	

func boss():
	pass

func _physics_process(delta: float) -> void:
	movement_timer += delta
	
	if movement_timer >= time_to_change_direction:
		changeDirection()
		movement_timer = 0
	
	velocity = direction * speed
	
	UpdateHealth()
	move_and_slide()
	deal_damage()
	
	if health <=150 and superMode == false:
		superMode = true 
		_animated_sprite.speed_scale = 3.0
		speed = 160
		
	
	
func changeDirection():
	#chose to move up/down or side to side
	if randf() > 0.5:
		#side to side
		direction.x = [-1, 1][randi() % 2] 
		direction.y = 0
	else:
		#up and down
		direction.x = 0
		direction.y = [-1, 1][randi() % 2] 

	
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




func _on_d_khitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles"):  # added functionality for when an enemy is hit by a projectile.
		health -= 50
		if health <= 0:
			self.queue_free()
			Global.playerScore +=1000
			SceneManager.Win()
