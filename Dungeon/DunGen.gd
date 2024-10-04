extends TileMapLayer


class_name DunGen
# Called when the node enters the scene tree for the first time.
var start:Vector2i
func _ready() -> void:
	start = Vector2i(0,0)
	for x in 8:
		start = _buildRect(start, randi_range(3,15), randi_range(3,7)) + Vector2i(randi_range(-2,-1), randi_range(-2,-1))

	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("PrimaryFire"):
		start = _buildRect(start, randi_range(3,15), randi_range(3,7)) + Vector2i(randi_range(-2,-1), randi_range(-2,-1))
	
	

func _buildRect(startCoord:Vector2i, sizeX:int, sizeY:int) -> Vector2i:
	var background:Vector2i = Vector2i(1,1) 
	var wall:Vector2i = Vector2i(3,2) 
	for x in sizeX:
		for y in sizeY:
			var pos: Vector2i = Vector2i(x,y)
			var isEdge:bool = (pos.x == 0 or pos.x == sizeX-1)
			var isWall:bool = (pos.y == 0 or pos.y == sizeY-1)
			if isEdge or isWall:
				set_cell(pos + startCoord, 0, wall, 0)
			else:
				set_cell(pos + startCoord, 0, background, 0)
	return startCoord + Vector2i(sizeX, sizeY)

func _buildRoom(room : Room)-> bool:
	
	
	
	return true

#rooms defined as 

# rooms are made of 1 or more rectangles
# if there is a function for building rooms, and the relative position of the doors are matching
#we should be able to run another room
# connect rooms with hallways
