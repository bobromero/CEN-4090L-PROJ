extends CharacterBody2D

class_name Player

static var Instance :Player

var enemy_in_damage_range = false # Range for player to deal damage to enemy
var enemy_in_attack_range = false # Range for player to take damage from enemy
var enemy_cooldown = true 
var player_attacking = false
var damage_applied = false
var knockback_velocity = Vector2.ZERO
var knockback_time = 0.0
var enemies_in_damage_range: Array = []

<<<<<<< HEAD
@onready var anim = $AnimatedSprite2D
@onready var attack_cooldown_timer = $AttackCooldown

@export var movement: movement = preload("res://Resources/PlayerResources/PlayerMovement.tres")
=======
@export var Movement: movement
>>>>>>> main
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
	Movement.SetPlayer(self)
	hud = $HUD
	Instance = self
	
func _equipWeapon():
	PlayerInventory.Weapon.attackRegion = attackRegion

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PrimaryFire") or event.is_action_pressed("SecondaryFire"):
		apply_damage_to_enemy()

func _process(delta: float) -> void:
	UpdateHealth()
	enemy_attack()
	
<<<<<<< HEAD
	movement._physics_process(delta)
=======
	if knockback_time > 0:
		position += knockback_velocity * delta
		knockback_time -= delta
	else:
		Movement._physics_process(delta)
	
	if health <= 0:
		SceneManager.Player_dead() #transitions to the death screen
>>>>>>> main
	
	if Input.is_action_just_pressed("PrimaryFire"):
		anim.play("proto_sword_attack")
		PlayerInventory.Weapon._primaryAttack()
	
	if Input.is_action_just_pressed("SecondaryFire"):
		anim.play("proto_magic_projectile")
		PlayerInventory.Weapon._secondaryAttack()
	
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
		enemies_in_damage_range.append(body)
		enemy_in_damage_range = true
		Global.player_attack_connect = true

func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemies_in_damage_range.erase(body)
		enemy_in_damage_range = false

func enemy_attack():
	if enemy_in_attack_range and enemy_cooldown == true:
		health -= 10
		flash_sprite()
		enemy_cooldown = false
		$DamageCooldown.start()

func player():
	pass

func addScore(amount: int) -> void:
	Global.playerScore += amount
	
func rmScore(amount: int) -> void:
	Global.playerScore -= amount
	if Global.playerScore < 0:
		Global.playerScore = 0

<<<<<<< HEAD
func apply_damage_to_enemy() -> void:
	for enemy in enemies_in_damage_range:
		if enemy.health > 0:  
			enemy.health -= 20
			enemy.UpdateHealth()
			enemy.apply_knockback_to_enemy()

		if enemy.health <= 0:
			enemy.queue_free()
			enemies_in_damage_range.erase(enemy)

		Global.player_attack_connect = false

func flash_sprite():
	anim.visible = false
	await get_tree().create_timer(0.1).timeout
	anim.visible = true
	await get_tree().create_timer(0.1).timeout
	if $DamageCooldown.is_stopped():
		anim.visible = true 
	else:
		flash_sprite()

func _on_damage_cooldown_timeout() -> void:
	enemy_cooldown = true
	anim.visible = true
=======
static func changePos(newPos:Vector2):
	Player.Instance.position = newPos;

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Door"):
		var room:DunRoom = area.get_parent() as DunRoom
		room.TouchedDoor(area)
>>>>>>> main
