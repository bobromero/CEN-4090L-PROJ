extends CharacterBody2D

class_name Player

@export var movement: movement
@export var PlayerInventory: Inventory = preload("res://Resources/Inventory/BaseInventory.tres")

@export var attackRegion: Area2D

@export var health: float = 100

@export var hud: playerHud
@export var currentscore = 0
@export var currentcoins = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.SetPlayer(self)
	hud = get_node("HUD")
	
	
	
func _equipWeapon():
	PlayerInventory.Weapon.attackRegion = attackRegion
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	item.OnPickup(self)
	#print(PlayerInventory.nonWeaponItems.size())
	
func RemoveFromInventory(id: int):
	PlayerInventory.RemoveItem(id)

func IncreaseHealth(num: float):
	health += num
	
	
	
func addCoin(int) -> void:
	currentcoins += int
	addScore(int*10)
	hud.update_coin(currentcoins)

#function to add 10 to the score
func addScore(int) -> void:
	currentscore += int
	hud.update_score(currentscore)
	
func rmScore(int) -> void:
	currentscore -= int
	hud.update_score(currentscore)
#func addScore(amount: int) -> void:
	#hud.addScore(amount)
	#
#func rmScore(amount: int) -> void:
	#hud.rmScore(amount)
