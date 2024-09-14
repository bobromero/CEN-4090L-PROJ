extends CharacterBody2D

@export var movement: movement
@export var Inventory: Inventory

@export var attackRegion: Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.SetPlayer(self)
	
func _equipWeapon():
	Inventory.Weapon.attackRegion = attackRegion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement._physics_process(delta)
	if Input.is_action_just_pressed("PrimaryFire"):
		Inventory.Weapon._primaryAttack()
		
	if Input.is_action_just_pressed("SecondaryFire"):
		Inventory.Weapon._secondaryAttack()
