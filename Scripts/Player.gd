extends CharacterBody2D

class_name Player

static var Instance :Player

var enemy_in_attack_range = false
var enemy_cooldown = true
var attack_ip = false
var knockback_velocity = Vector2.ZERO
var knockback_time = 0.0

@export var movement: movement
@export var PlayerInventory: Inventory = preload("res://Resources/PlayerResources/BaseInventory.tres")
@export var attackRegion: Area2D
@export var health: float = 100
@export var knockback_strength = 100
@export var knockback_duration = 0.2

@export var hud: playerHud

@onready var anim = $AnimatedSprite2D

#@export var Score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.SetPlayer(self)
	hud = $HUD
	Instance = self
	
		
	
	
func _equipWeapon():
	PlayerInventory.Weapon.attackRegion = attackRegion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	UpdateHealth()
	enemy_attack()
	
	if knockback_time > 0:
		position += knockback_velocity * delta
		knockback_time -= delta
	else:
		movement._physics_process(delta)
	
	if health <= 0:
		SceneManager.Player_dead() #transitions to the death screen
	
	if Input.is_action_just_pressed("PrimaryFire"):
		anim.play("proto_sword_attack")
		PlayerInventory.Weapon._primaryAttack()
		
	if Input.is_action_just_pressed("SecondaryFire"):
		anim.play("proto_magic_projectile")
		PlayerInventory.Weapon._secondaryAttack()
		
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
		apply_knockback(body)

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false
		
func enemy_attack():
	if enemy_in_attack_range and enemy_cooldown == true:
		health -= 10
		enemy_cooldown = false
		$DamageCooldown.start()

func player():
	pass

func _on_damage_cooldown_timeout():
	enemy_cooldown = true
	
func attack():
	var direction := Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("melee"):
		Global.player_current_attack = true
		attack_ip = true

func _on_attack_cooldown_timeout() -> void:
	$AttackCooldown.stop()
	Global.player_current_attack = false
	attack_ip = false
	
func apply_knockback(body: Node2D):
	var direction = (position - body.position).normalized()
	knockback_velocity = direction * knockback_strength / knockback_duration
	knockback_time = knockback_duration

func addScore(amount: int) -> void:
	Global.playerScore += amount
	
	
func rmScore(amount: int) -> void:
	Global.playerScore -= amount
	if Global.playerScore < 0:
		Global.playerScore = 0


func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Door"):
		var room:DunRoom = area.get_parent() as DunRoom
		room.TouchedDoor(area)
