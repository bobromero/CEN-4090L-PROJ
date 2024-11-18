using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Dungen : Node2D {
	
	public class Dungeon {
		public String[] StartPaths = new string[] {
			"res://Prefabs/Rooms/room0.tscn",
			"res://Prefabs/Rooms/room1.tscn"
		};
		public String[] CommonPaths = new string[] {
			"res://Prefabs/Rooms/room0.tscn",
			"res://Prefabs/Rooms/room1.tscn"
		};
		public String[] LootPaths = new string[] {
			"res://Prefabs/Rooms/room0.tscn",
			"res://Prefabs/Rooms/room1.tscn"
		};
		public String[] BossPaths = new string[] {
			"res://Prefabs/Rooms/room0.tscn",
			"res://Prefabs/Rooms/room1.tscn"
		};
		Room StartRoom;
		public int roomCount = 0;
		public int MaxDepth; // how long before force terminating a path
		public bool hasBoss = false;
		public Node HostNode;

		public Dungeon(Node host, int maxDepth) {
			HostNode = host;
			MaxDepth = maxDepth;
			TileMapLayer Layer = (TileMapLayer)GD.Load<PackedScene>(StartPaths[0]).Instantiate();
			HostNode.AddChild(Layer);
			Room.Door door = new Room.Door {
				offset = Layer.GetChild(0).GetChild<Node2D>(0).Position,
				direction = Room.Door.Direction.North,
				GlobalPos = new Vector2(0, 0)
			};

			Room room = new Room(Layer, roomCount++, door);
			room.GenerateNeighbors(this, room, door, 0);
		}
	}

	public class Room
	{
		public enum RoomType{
			Start, // start room
			Common, // enemy room
			Loot, //end room
			Boss // end boss room, only 1

		}
		public class Door
		{
			public enum Direction {
				North,
				South,
				East,
				West
			}
			public Direction direction;
			public Vector2 GlobalPos;
			public Vector2 offset;
		}
		public Node2D Self;
		private int id;

		private Door[] doors;
		public Door[] Doors {
			private set { this.doors = value; }
			get { return this.doors; }
		}

		private Room[] Neighbors;
		private Door Connector;


		public Room(Node2D self, int _id, Door connector) {
			Self = self;
			id = _id;
			doors = GetDoors(self);
			Connector = connector;
		}

		public Door[] GetDoors(Node Scene) {
			Node[] input = Scene.GetChildren().Where(r => r.GetChild(0).Name.ToString().Contains("Door")).ToArray();
			Door[] result = new Door[input.Count()];

			for (int i = 0; i < input.Count(); i++)
			{
				Door.Direction pos = Door.Direction.North;

				switch (input[i].Name.ToString()[0]) {
					case 'N':
						pos = Door.Direction.North;
						break;
					case 'E':
						pos = Door.Direction.East;
						break;
					case 'S':
						pos = Door.Direction.South;
						break;
					case 'W':
						pos = Door.Direction.West;
						break;
					default:
						break;
				}
				var _offset = input[i].GetChild<Node2D>(0).Position;
				GD.Print(input[i].GetChild<Node2D>(0).Name.ToString());
				result[i] = new Door {
					direction = pos,
					offset = _offset,
					GlobalPos = _offset
				};
			}
			return result.ToArray();
		}
		
		public void GenerateNeighbors(Dungeon d, Room ParentRoom, Door connectedDoor, int depth) {
			if (depth >= d.MaxDepth) {
				return;
			}
			Neighbors = new Room[doors.Count()];
			Neighbors[0] = ParentRoom;

			Door CorrespondingDoor = new Door();
			switch (connectedDoor.direction) {
				case Door.Direction.North:
					CorrespondingDoor.direction = Door.Direction.South;
					break;
				case Door.Direction.South:
					CorrespondingDoor.direction = Door.Direction.North;
					break;
				case Door.Direction.East:
					CorrespondingDoor.direction = Door.Direction.West;
					break;
				case Door.Direction.West:
					CorrespondingDoor.direction = Door.Direction.East;
					break;
				default:
					break;
			}

			for (int i = 0; i < doors.Count(); i++)
			{
				if (doors[i].direction == CorrespondingDoor.direction)
				{
					CorrespondingDoor.offset = doors[i].offset;
				}
			}
			for (int i = 1; i < doors.Count(); i++) {
				var scene = SpawnRoom(d, depth);
				d.HostNode.AddChild(scene);



				scene.GlobalPosition = connectedDoor.GlobalPos;

				Room room = new Room(scene, d.roomCount++, doors[i]);

				GD.Print("Corresponding Door " + CorrespondingDoor.GlobalPos);
				GD.Print("Room Pos " + room.Self.GlobalPosition);

				doors[i].GlobalPos = scene.GlobalPosition + doors[i].offset;

				Neighbors[i] = room;
				Neighbors[i].GenerateNeighbors(d, this, doors[i], ++depth);
			}
		}


		private TileMapLayer SpawnRoom(Dungeon d,int depth) {
			RoomType type;

			if (depth > d.MaxDepth - 1) {
				if (d.hasBoss) {
					type = RoomType.Loot;

				} else {
					type = RoomType.Boss;
					d.hasBoss = true;
				}
			} else {
				type = RoomType.Common;
			}

			String path = "";

			Random rand = new Random();
			switch (type) {
				case RoomType.Common:
					path = d.CommonPaths[rand.Next(0, d.CommonPaths.Count())];
					// GD.Print("Spawning Common");
					break;
				case RoomType.Loot:
					path = d.LootPaths[rand.Next(0, d.LootPaths.Count())];
					// GD.Print("Spawning Loot");
					break;
				case RoomType.Boss:
					path = d.BossPaths[rand.Next(0, d.BossPaths.Count())];
					// GD.Print("Spawning Boss");
					break;
				default:
					break;
			}
			return (TileMapLayer)GD.Load<PackedScene>(path).Instantiate();
			
		}

		//public void GeneratNeighbors(Dungeon d, Room ParentRoom, Door connectedDoor, int depth) {
		//	if (depth >= d.MaxDepth) {
		//		return;
		//	}
		//	Neighbors = new Room[doors.Count()];
		//	Neighbors[0] = ParentRoom;

		//	Door CorrespondingDoor = new Door();
		//	switch (connectedDoor.direction) {
		//		case Door.Direction.North:
		//			CorrespondingDoor.direction = Door.Direction.South;
		//			break;
		//		case Door.Direction.South:
		//			CorrespondingDoor.direction = Door.Direction.North;
		//			break;
		//		case Door.Direction.East:
		//			CorrespondingDoor.direction = Door.Direction.West;
		//			break;
		//		case Door.Direction.West:
		//			CorrespondingDoor.direction = Door.Direction.East;
		//			break;
		//		default:
		//			break;
		//	}
		//	CorrespondingDoor.GlobalPos = new Vector2(0, 0);
		//	CorrespondingDoor.GlobalPos += connectedDoor.offset;
		//	CorrespondingDoor.offset = (doors.Where(door => door.direction == CorrespondingDoor.direction) as Door).offset;

		//          for (int i = 1; i < doors.Count(); i++) {
		//              var scene = SpawnRoom(d, depth);
		//              d.HostNode.AddChild(scene);

		//              scene.GlobalPosition = connectedDoor.GlobalPos + CorrespondingDoor.offset;

		//              Room room = new Room(scene, d.roomCount++, doors[i]);

		//              //GD.Print("Corresponding Door " + CorrespondingDoor.offset + " " +  CorrespondingDoor.direction);
		//              GD.Print("Room Pos " + room.Self.GlobalPosition);

		//              Neighbors[i] = room;
		//          }
		//          for (int i = 1; i < Neighbors.Length; i++) {
		//              depth++;
		//              Neighbors[i].GenerateNeighbors(d, this, doors[i], depth);
		//          }
		//      }


	}


	List<Room> rooms = new List<Room>();

	Dungeon dungeon;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
		dungeon = new Dungeon(this, 2);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionJustPressed("PrimaryFire")) {
			GD.Print("Hello");
			
		}
	}

	/**
	 *	I need to know where the doors are for each room
	 *	I can add a door to each scene as well as a teleporter, and when I change the room, I can get the coresponding door
	 */



	//spawn room
	//add offset to room
	//that offset is the local position of the corresponding door
	//send down and repeat

	//room spawns at 0,0
	//spawn new room
	//new room spawns at 0,0
	//move new room to room.connectedDoor.doorGlobalPos
	//add new room's corresponding doorPos offset
	//repeat
}
