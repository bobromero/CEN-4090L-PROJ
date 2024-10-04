extends Node


@export var item:Item


var _playerEnetered: bool = false
var _enemyEntered: bool = false
var playerScript: Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pickup") and _playerEnetered:
		playerScript.AddToInventory(item)
		queue_free()
	elif _enemyEntered:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	#print("Entered: " + area.get_parent().name)
	_playerEnetered = area.is_in_group("Inventory") and area.is_in_group("Player")
	playerScript = area.get_parent().get_script().new()
	
	_enemyEntered = area.is_in_group("Inventory") and area.is_in_group("Enemy")

#when the coin is encountered
func _on_coin_entered(coin: Area2D) -> void:
	print(str("coin entered"))
	if coin.is_in_group("Player"):
		var player = coin.get_parent() as Player  #Get the Player instance
		if player != null:
			player.addCoin(1) 
			queue_free()  #delete the coin
		else:
			print("Error: Could not find the player instance")
	#playerScript.addScore(10)
	


func _on_area_2d_area_exited(area: Area2D) -> void:
	#print("Exited: " + area.get_parent().name)
	if area.is_in_group("Inventory") and area.is_in_group("Player"):
		_playerEnetered = false
	if area.is_in_group("Inventory") and area.is_in_group("Enemy"):
		_enemyEntered = false
	pass
