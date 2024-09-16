class_name Room

    var id: int
    var is_starting_room: bool = false
    var connected_rooms: Array = []

    func _init(new_id: int, starting_room: bool = false): 
        id = new_id
        is_starting_room = starting_room
        if is_starting_room:             #Create passive starting room 
            new_id = 0 
            connected_rooms = []

    func connect_room(room: Room):       #Connects rooms to each other
        connected_rooms.append(room)

    func generate_random_room():         #Randomly selects from the premade item pool
        var room = Room.new()
        room.id = randi()    
        return room
