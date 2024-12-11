extends CharacterBody2D


@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 80    # Higher speed = slower enemy and vice versa
var health
@export var MaxHealth = 1000

var superMode =false
var player_in_attack_range = false
var player_chase = false
var player = null
var direction = Vector2.RIGHT  # Initial movement direction
var movement_timer = 0
var time_to_change_direction = 3.0
var invincible = false

const IFRAMESTIME = 2
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	_animated_sprite.play("default")
	health = MaxHealth
	

func boss():
	pass

func _physics_process(delta: float) -> void:
	movement_timer += delta
	
	if health != MaxHealth:
		Global.isInBossFight = true
	if movement_timer >= time_to_change_direction:
		changeDirection()
		movement_timer = 0
	
	velocity = direction * speed
	
	UpdateHealth()
	move_and_slide()
	
	if health <= MaxHealth/3 and superMode == false:
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

	if health >= MaxHealth:
		healthBar.visible = false
	else:
		healthBar.visible = true
		
	if health <= 0:
		Global.playerScore +=1000
		SceneManager.Win()


func TakeDamage(amount: int):
	if invincible == false:
		health-=amount
		invincible = true
		_animated_sprite.play("Flash")
		await get_tree().create_timer(IFRAMESTIME).timeout
		_animated_sprite.play("default")
		invincible = false
		
#
#func _on_d_khitbox_body_entered(body: Node2D) -> void:
	#if body.is_in_group("projectiles"):  # added functionality for when an enemy is hit by a projectile.
		#health -= 50
		#if health <= 0:
			#self.queue_free()
			#Global.playerScore +=1000
			#SceneManager.Win()
