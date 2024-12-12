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

@onready var anim = $AnimatedSprite2D
#@onready var attack_cooldown_timer = $AttackCooldown

@onready var movement: movement = preload("res://Resources/PlayerResources/PlayerMovement.tres")
@onready var PlayerInventory: Inventory = preload("res://Resources/PlayerResources/BaseInventory.tres")
@export var attackRegion: Area2D
@export var health: float = 100
@export var knockback_strength = 100
@export var knockback_duration = 0.2
@export var attack_duration = 1

var canMove = true;

var attack_animations: Dictionary = {
	"magic_projectile": true,
	"Sword": true,
	"Sword_up": true,
	"Sword_down": true,
}

var hud: playerHud

# @export var Score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.SetPlayer(self)
	anim.connect("animation_finished", Callable(self, "_on_AnimatedSprite_Anim_Finished"))
	print("Connected animation_finished signal")
	hud = $HUD
	Instance = self
	
# Called when signal is set to alert that the animation has ended. Enusres that
# idle animation restarts after player is finished attacking
func _on_AnimatedSprite_Anim_Finished():
	if anim.animation in attack_animations:
		if anim.animation == "magic_projectile" or anim.animation == "Sword":
			print ("Stopping animation")
		
		player_attacking = false
	
	
func _equipWeapon():
	PlayerInventory.Weapon.attackRegion = attackRegion

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PrimaryFire") or event.is_action_pressed("SecondaryFire"):
		apply_damage_to_enemy()

func _process(delta: float) -> void:
	UpdateHealth()
	
	movement._physics_process(delta)
	var direction := Input.get_vector("left", "right", "up", "down")
	#Gets direction since from input since I can't get it from movement.gd
	
	if knockback_time > 0:
		position += knockback_velocity * delta
		knockback_time -= delta
	else:
		movement._physics_process(delta)
	
	if health <= 0:
		SceneManager.Player_dead() #transitions to the death screen
	
	if Input.is_action_just_pressed("PrimaryFire"):	#Plays different directinal animations
		player_attacking = true
		if direction.y > 0:
			anim.play("Sword_down")
		elif direction.y < 0:
			anim.play("Sword_up")
		elif (anim.animation!= "Sword"):
			anim.play("Sword")
		
	
		PlayerInventory.Weapon._primaryAttack()
		
		
	
	if Input.is_action_just_pressed("SecondaryFire"):
		player_attacking = true
		if (anim.animation!= "magic_projectile"):
			anim.play("magic_projectile")
		print("Playing projecile animation")
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
	
func TakeDamage(num: int):
	health -= num
	
func UpdateHealth():
	var healthBar = $HealthBar
	healthBar.value = health
	
	if health >= 200:
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
	if body.has_method("boss"):
		print("boss touched")
		TakeDamage(50)
		
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.is_in_group("Enemy"):
		enemies_in_damage_range.append(body)
		enemy_in_damage_range = true
		Global.player_attack_connect = true

func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemies_in_damage_range.erase(body)
		enemy_in_damage_range = false

func enemy_attack():
	TakeDamage(10)
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

func _on_damage_cooldown_timeout() -> void:
	enemy_cooldown = true
	anim.visible = true

static func changePos(newPos:Vector2):
	Player.Instance.position = newPos;

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Door"):
		var room:DunRoom = area.get_parent().get_parent() as DunRoom
		room.TouchedDoor(area)
		
		
