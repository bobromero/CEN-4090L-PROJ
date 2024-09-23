extends TileMapLayer


class_name DunGen
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	for x in 10:
		for y in 10:
			print(x,y)
			set_cell(Vector2i(x,y), 0, Vector2i(1,1), 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _buildRoom(room : Room)-> bool:
	
	
	
	return true

#rooms defined as 

# rooms are made of 1 or more rectangles
# if there is a function for building rooms, and the relative position of the doors are matching
#we should be able to run another room
# connect rooms with hallways
