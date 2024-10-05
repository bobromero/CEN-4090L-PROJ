extends CharacterBody2D

class_name Player

@export var movement: movement
@export var PlayerInventory: Inventory = preload("res://Resources/Inventory/BaseInventory.tres")

@export var attackRegion: Area2D

@export var health: float = 100

@export var hud: playerHud
@export var currentscore = 0
@export var currentcoins = 0

@export var knockback_strength = 500
@export var knockback_duration = 0.2
@export var knockback_enabled = false
@export var knockback_timer = 0.0  


var enemy_in_attack_range = false
var enemy_cooldown = true
var player_alive = true
var knockback_velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.SetPlayer(self)
	hud = get_node("HUD")
	
func _equipWeapon():
	PlayerInventory.Weapon.attackRegion = attackRegion
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	enemy_attack()
	UpdateHealth()
	
	if health <= 0:
		player_alive = false
		health = 0 
		self.queue_free() # Temporary holder for player death
	
	if knockback_enabled:
		apply_knockback(delta)
	
	else:	
		movement._physics_process(delta)
	
	if Input.is_action_just_pressed("PrimaryFire"):
		PlayerInventory.Weapon._primaryAttack()
		
	if Input.is_action_just_pressed("SecondaryFire"):
		PlayerInventory.Weapon._secondaryAttack()

	#if PlayerInventory.nonWeaponItems.size() > 0 and Input.is_action_just_pressed("pickup"):
		#UseItem(0) #or selected index some how

func UseItem(id: int):
	PlayerInventory.nonWeaponItems[id].Use(self)
	RemoveFromInventory(id)

func AddToInventory(item: Item):
	PlayerInventory.AddItem(item)
	
func RemoveFromInventory(id: int):
	PlayerInventory.RemoveItem(id)

func IncreaseHealth(num: float):
	health += num
	
func UpdateHealth():
	var healthBar = $HealthBar
	healthBar.value = health
	
	if health >= 100:
		healthBar.visible = false
	else:
		healthBar.visible = true
		
	
func player():
	pass

func apply_knockback_to_player(body: Node2D):
	if not knockback_enabled:
		var direction = (position - body.position).normalized()
		knockback_velocity = direction * knockback_strength
		knockback_enabled = true
		knockback_timer = knockback_duration

func apply_knockback(delta: float) -> void:
	position += knockback_velocity * delta
	knockback_timer -= delta
	if knockback_timer <= 0:
		knockback_enabled = false
		knockback_velocity = Vector2.ZERO

func enemy_attack():
	if enemy_in_attack_range and enemy_cooldown:
		health = health - 10
		enemy_cooldown = false
		$DamageCooldown.start()

func addScore(amount: int) -> void:
	hud.addScore(amount)
	
func rmScore(amount: int) -> void:
	hud.rmScore(amount)

func _on_damage_cooldown_timeout() -> void:
	enemy_cooldown = true


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true
		apply_knockback_to_player(body)

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false
