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
	#get_tree().root.find_child("DungeonManager") as 
	print("Touched door")
