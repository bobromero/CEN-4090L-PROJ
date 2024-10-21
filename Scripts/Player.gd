extends CharacterBody2D

class_name Player

@export var movement: movement
@export var PlayerInventory: Inventory = preload("res://Resources/Inventory/BaseInventory.tres")

@export var attackRegion: Area2D

@export var health: float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.SetPlayer(self)
	
	
func _equipWeapon():
	PlayerInventory.Weapon.attackRegion = attackRegion
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement._physics_process(delta)
	if Input.is_action_just_pressed("PrimaryFire"):
		PlayerInventory.Weapon._primaryAttack()
		
	if Input.is_action_just_pressed("SecondaryFire"):
		PlayerInventory.Weapon._secondaryAttack()
		
	if PlayerInventory.nonWeaponItems.size() > 0 and Input.is_action_just_pressed("pickup"):
		UseItem(0) #or selected index some how

func UseItem(id: int):
	PlayerInventory.nonWeaponItems[id].Use(self)
	RemoveFromInventory(id)

func AddToInventory(item: Item):
	PlayerInventory.AddItem(item)
	
func RemoveFromInventory(id: int):
	PlayerInventory.RemoveItem(id)

func IncreaseHealth(num: float):
	health += num
	
