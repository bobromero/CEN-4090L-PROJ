extends Node2D 

@onready var enemy= preload("res://Prefabs/Enemy.tscn")

var canSpawn = true

func _ready():
	pass

func _process(_delta: float) -> void:
	if Global.isInBossFight == true and canSpawn == true:
		spawn_enemy()
		canSpawn = false
		await get_tree().create_timer(30.0).timeout
		canSpawn = true
		

func spawn_enemy():
	var newEnemy = enemy.instantiate()
	
	
	var randomOffset = Vector2(
		randf_range(-500, 500), 
		randf_range(-500, 500)   
	)
	
	
	newEnemy.global_position = global_position + randomOffset
	
	get_tree().current_scene.add_child(newEnemy)
