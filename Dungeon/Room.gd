extends TileMapLayer

class_name DunRoom

@export var NorthDoor:Area2D
@export var SouthDoor:Node2D
@export var EastDoor:Node2D
@export var WestDoor:Node2D

func _ready() -> void:
	pass

func TouchedDoor(area : Area2D):
	var MyCSharpScript = load("res://Dungeon/Dungen.cs")
	var myNode = MyCSharpScript.new()
	var dir:int = -1
	if area == NorthDoor:
		dir = 0
	elif area == SouthDoor:
		dir = 1
	elif area == EastDoor:
		dir = 2
	elif area == WestDoor:
		dir = 3
		
	#This is an abomination but blame godot not me entirely
	myNode.ChangeDirection(dir)
