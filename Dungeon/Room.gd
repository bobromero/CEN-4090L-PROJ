extends TileMapLayer

class_name DunRoom

@export var NorthDoor:Node2D
@export var SouthDoor:Node2D
@export var EastDoor:Node2D
@export var WestDoor:Node2D

@export var activationArea:Area2D

func _ready() -> void:
	activationArea.area_entered.connect(WalkedIn)


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
	myNode.ChangeDirection(dir, Player)

func WalkedIn(area:Area2D):
	var MyCSharpScript = load("res://Dungeon/Dungen.cs")
	var myNode = MyCSharpScript.new()
	if area.is_in_group("Player"):
		myNode.WalkedIn()
