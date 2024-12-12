extends TileMapLayer

class_name DunRoom


@export var NorthDoor:Node2D
@export var SouthDoor:Node2D
@export var EastDoor:Node2D
@export var WestDoor:Node2D

@export var activationArea:Area2D

static var RoomScale:Vector2 = Vector2(10,10)

var MyCSharpScript
var myNode
func _ready() -> void:
	MyCSharpScript = load("res://Dungeon/Dungen.cs")
	myNode = MyCSharpScript.new()
	activationArea.area_entered.connect(WalkedIn)
	
	scale = RoomScale

func _process(_delta: float) -> void:
	openCondition()

func TouchedDoor(area : Area2D):
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
	Player.Instance.canMove = false
	#PlayerCamera.Instance.TransitionIn()
	
	myNode.ChangeDirection(dir, Player, PlayerCamera.Instance)
	PlayerCamera.Instance.TransitionOut()
	Player.Instance.canMove = true
	
	

func WalkedIn(area:Area2D):
	if area.is_in_group("Player"):
		myNode.WalkedIn()

func openCondition():
	if $Entities.get_children().size() == 0:
		myNode.OpenRoomCondition()
