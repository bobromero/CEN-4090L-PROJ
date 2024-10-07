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
	_CreateRooms() 
	_CreateDoors()
	#_GenHallways()
	_PaintRooms()

func _CreateRooms():
	var partitions:int = 4 #cube with height = n and width = n
	var partitionSize:Vector2i = Vector2i(40,20)#is a vector for the ability to have rectangular partitions if needed
	var SmallestRoom:int = 19
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
			rooms.append(room)
	#partions that each have 1 room
	#partition gap allows for space between rooms
	#build 1 room in each partition, then paint
	#generate number size.x / n and add start point

func _CreateDoors():
	var doorSize = 3;
	for room in rooms:
		
		for x in 4: #possible door ways
			var rand:int = randi_range(1,4)
			if rand <=2:
				continue
			var position:Vector2i = room.startPos
			var randShiftX:int = randi_range(0,(room.Dimensions.x / doorSize) - 2) #2 for each corner
			var randShiftY:int = randi_range(0,(room.Dimensions.y / doorSize) - 2) #2 for each corner
			if x == 0: #top
				position.x += (room.Dimensions.x / 2) - 1 + randShiftX
				room.Doors.append(position)
				position.x += 1
				room.Doors.append(position)
				position.x -= 2
				room.Doors.append(position)
			elif x == 1: #left
				position.y += (room.Dimensions.y / 2) - 1 + randShiftY
				room.Doors.append(position)
				position.y += 1
				room.Doors.append(position)
				position.y -= 2
				room.Doors.append(position)
			elif x == 2: #right
				position.y += (room.Dimensions.y / 2) - 1 + randShiftY
				position.x += room.Dimensions.x - 1
				room.Doors.append(position)
				position.y += 1
				room.Doors.append(position)
				position.y -= 2
				room.Doors.append(position)
			elif x == 3: #bottom
				position.y += room.Dimensions.y - 1
				position.x += (room.Dimensions.x / 2) - 1 + randShiftX
				room.Doors.append(position)
				position.x += 1
				room.Doors.append(position)
				position.x -= 2
				room.Doors.append(position)
			
		#door will be on the edge
		#not close to the corner
		#3 blocks long
		#right edge is startpos.x + size.x -1
		#left edge is startpos.x
		#top edge is startpos.y
		#bottom edge is startpos.y + size.y - 1
		#bottom middle for example will be y = startpos.y + size.y - 1 and x = startpos.x + (size.x / 2) - 1
		#we can add a random shift of (size/3) - 2

func _erase():
	var cells = get_used_cells()
	for c in cells:
		erase_cell(Vector2i(c.x, c.y))
	rooms.clear()

func _PaintRooms():
	for room in rooms:
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
				
		for door in room.Doors:
			erase_cell(door)
				
