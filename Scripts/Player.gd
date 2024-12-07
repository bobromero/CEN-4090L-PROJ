extends CharacterBody2D

class_name Player

static var Instance :Player

var enemy_in_damage_range = false # Range for player to deal damage to enemy
var enemy_in_attack_range = false # Range for player to take damage from enemy
var enemy_cooldown = true 
var player_attacking = false
var damage_applied = false
var player_attack_cooldown = true
var knockback_velocity = Vector2.ZERO
var knockback_time = 0.0

@onready var anim = $AnimatedSprite2D
@onready var attack_cooldown_timer = $AttackCooldown

@export var movement: movement = preload("res://Resources/PlayerResources/PlayerMovement.tres")
@export var PlayerInventory: Inventory = preload("res://Resources/PlayerResources/BaseInventory.tres")
@export var attackRegion: Area2D
@export var health: float = 100
@export var knockback_strength = 100
@export var knockback_duration = 0.2
@export var attack_duration = 1

var hud: playerHud

# @export var Score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.SetPlayer(self)
	hud = $HUD
	Instance = self
	
func _equipWeapon():
	PlayerInventory.Weapon.attackRegion = attackRegion

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PrimaryFire") or event.is_action_pressed("SecondaryFire"):
		apply_damage_to_enemy()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	UpdateHealth()
	enemy_attack()
	
	movement._physics_process(delta)
	
	if health <= 0:
		SceneManager.Player_dead() #transitions to the death screen
		
	if PlayerInventory.nonWeaponItems.size() > 0 and Input.is_action_just_pressed("pickup"):
		UseItem(0) # or selected index somehow
	

func UseItem(id: int):
	PlayerInventory.nonWeaponItems[id].Use(self)
	RemoveFromInventory(id)

func AddToInventory(item: Item):
	PlayerInventory.AddItem(item)
	item.OnPickup(self)
	#print(PlayerInventory.nonWeaponItems)
	
func RemoveFromInventory(id: int):
	if id>=0:
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

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true
		print("Enemy in attack range")

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_damage_range = true
		Global.player_attack_connect = true
		print("Enemy can be attacked", "\nAttack Connect = ", Global.player_attack_connect)

func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_damage_range = false
		print("Enemy cannot be attacked", "\nAttack Connect = ", Global.player_attack_connect)

func enemy_attack():
	if enemy_in_attack_range and enemy_cooldown == true:
		health -= 10
		enemy_cooldown = false
		$DamageCooldown.start()

func player():
	pass

func _on_damage_cooldown_timeout():
	enemy_cooldown = true

func _on_attack_cooldown_timeout():
	player_attack_cooldown = true

func addScore(amount: int) -> void:
	Global.playerScore += amount
	
func rmScore(amount: int) -> void:
	Global.playerScore -= amount
	if Global.playerScore < 0:
		Global.playerScore = 0

func apply_damage_to_enemy() -> void:
	if not damage_applied:  # Prevent continuous damage
		if (Input.is_action_just_pressed("PrimaryFire") or Input.is_action_just_pressed("SecondaryFire")) and player_attack_cooldown:
			damage_applied = true
			player_attack_cooldown = false
			attack_cooldown_timer.start()

	# Play the appropriate attack animation
	if Input.is_action_just_pressed("PrimaryFire"):
		anim.play("proto_sword_attack")
		PlayerInventory.Weapon._primaryAttack()
	elif Input.is_action_just_pressed("SecondaryFire"):
		anim.play("proto_magic_projectile")
		PlayerInventory.Weapon._secondaryAttack()

	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy.is_in_group("Enemy"):
			enemy.health -= 20
			print("Enemy took 20 damage")
			enemy.UpdateHealth()
			enemy.apply_knockback_to_enemy()
		if enemy.health <= 0:
			enemy.queue_free()
			break

		Global.player_attack_connect = false
