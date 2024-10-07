extends TileMapLayer


class_name DunGen

var rooms:Array[Room] = []
var background:Vector2i = Vector2i(1,1) 
var wall:Vector2i = Vector2i(3,2) 

func _ready() -> void:
	_generate()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("PrimaryFire"):
		_erase()
		_generate()
	pass
	
func _generate():
		var partitions:int = 3 #cube with height = n and width = n
		var partitionSize:Vector2i = Vector2i(20,20)#is a vector for the ability to have rectangular partitions if needed
		var SmallestRoom:int = 5 
		var startPoint:Vector2i = Vector2i(0,0) #start of partition is coords(ex. 0,1) * partitionSize
		var roomSize:Vector2i
		for x in partitions:
			for y in partitions:
				var dimension : Vector2i = Vector2i(x,y) * partitionSize
				var randLeftPadding:int = randi_range(1,partitionSize.x - SmallestRoom)
				var randRightPadding:int = randi_range(1, randLeftPadding) - 1
				startPoint.x = dimension.x + randLeftPadding - randRightPadding
				roomSize.x = partitionSize.x - randLeftPadding
				var randUpPadding:int = randi_range(1,partitionSize.y - SmallestRoom)
				var randDownPadding:int = randi_range(1, randUpPadding) - 1
				startPoint.y = dimension.y + randUpPadding - randDownPadding
				roomSize.y = partitionSize.y - randUpPadding
				
				var room : Room = Room.new(startPoint, roomSize)
				_paintRoom(room)
		#partions that each have 1 room
		#build 1 room in each partition, then paint
		#generate number size.x / n and add start point

func _erase():
	var cells = get_used_cells()
	for c in cells:
		erase_cell(Vector2i(c.x, c.y))

func _paintRoom(room:Room):
	for x in room.Dimensions.x:
		for y in room.Dimensions.y:
			var pos: Vector2i = Vector2i(x,y)
			var offset: Vector2i = room.startPos
			set_cell(pos + offset, 0, wall, 0)
	for x in room.Dimensions.x - 2:
		for y in room.Dimensions.y - 2:
			var pos: Vector2i = Vector2i(x + 1,y + 1)
			var offset: Vector2i = room.startPos
			set_cell(pos + offset, 0, background, 0)
			
