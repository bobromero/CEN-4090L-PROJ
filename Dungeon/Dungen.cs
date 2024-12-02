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
		public Room ActiveRoom;
		public int roomCount = 0;
		public int MaxDepth; // how long before force terminating a path
		public bool hasBoss = false;
		public Node HostNode;

		public Dungeon(Node host, int maxDepth) {
			HostNode = host;
			MaxDepth = maxDepth;

			TileMapLayer Layer = (TileMapLayer)GD.Load<PackedScene>(StartPaths[0]).Instantiate();
			HostNode.AddChild(Layer);

			GD.Print("Start Room");

			Room room = new Room(Layer, roomCount++);
			ActiveRoom = room;
			room.GenerateNeighbors(this, room, Room.Door.Direction.StartDir, 0);
		}

		public void ChangeActiveRoom(Room newActiveRoom) {
			ActiveRoom.ChangeRoomActive(false);
			ActiveRoom = newActiveRoom;
			ActiveRoom.ChangeRoomActive(true);
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
				West,
				StartDir
			}

			public static Direction IntToDirection(int number) {
				switch (number) {
					case 0:
						return Direction.North;
					case 1:
						return Direction.South;
					case 2:
						return Direction.West;
					case 3:
						return Direction.East;
					default:
						break;
				}
				return Direction.StartDir;
			}

			public Direction direction;
		}
		public Node2D Self;
		private int id;

		private Door[] doors;
		public Door[] Doors {
			private set { this.doors = value; }
			get { return this.doors; }
		}

		private Dictionary<Door.Direction, Room> Neighbors;

		public void ChangeRoomActive(bool value) {
			Self.Visible = value;
			foreach (Area2D child in Self.GetChildren()) {
				child.ProcessMode = ProcessModeEnum.Inherit;
			}
			Self.ProcessMode = (value == true ? ProcessModeEnum.Always: ProcessModeEnum.Disabled);
			Self.SetProcess(value);
		}

		public Room(Node2D self, int _id) {
			Self = self;
			id = _id;
			doors = GetDoors(self);
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
				//GD.Print(input[i].GetChild<Node2D>(0).Name.ToString());
				result[i] = new Door {
					direction = pos,
				};
			}
			return result.ToArray();
		}
		
		public void GenerateNeighbors(Dungeon d, Room ParentRoom, Door.Direction connectedDir, int depth) {
			if (depth >= d.MaxDepth) {
				return;
			}
			Neighbors = new Dictionary<Door.Direction, Room>();
			Neighbors[connectedDir] = ParentRoom;

			for (int i = 0; i < doors.Count(); i++) {
				
				if (connectedDir == Door.IntToDirection(i))
				{
					continue;
				}

				Door.Direction workingNeighbor = Door.IntToDirection(i);
				
				Room room = MakeRoom(d, depth);

				Neighbors[workingNeighbor] = room;
				room.ChangeRoomActive(false);
				Neighbors[workingNeighbor].GenerateNeighbors(d, this, workingNeighbor, depth + 1);
			}
		}


		private Room MakeRoom(Dungeon d,int depth) {
			RoomType type;

			if (depth >= d.MaxDepth - 1) {
				if (d.hasBoss) {
					type = RoomType.Loot;
					//add ending common loot room
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
					GD.Print("Spawning Common");
					break;
				case RoomType.Loot:
					path = d.LootPaths[rand.Next(0, d.LootPaths.Count())];
					GD.Print("Spawning Loot");
					break;
				case RoomType.Boss:
					path = d.BossPaths[rand.Next(0, d.BossPaths.Count())];
					GD.Print("Spawning Boss");
					break;
				default:
					break;
			}
			RandomNumberGenerator rng = new RandomNumberGenerator();
			var scene = (TileMapLayer)GD.Load<PackedScene>(path).Instantiate();
			scene.Modulate = Color.Color8((byte)(rng.Randi()%255), (byte)(rng.Randi() % 255), (byte)(rng.Randi() % 255));
			d.HostNode.AddChild(scene);
			return new Room(scene, d.roomCount++);
		}

		
		public Room GetNeighbor(Door.Direction direction) {
			return Neighbors[direction];
		}
	}


	List<Room> rooms = new List<Room>();

	public static Dungeon dungeon;

	private static Room.Door.Direction direction = Room.Door.Direction.StartDir; //used as an interface between godot and c#

	public static double RoomChangeBuffer = 2;

	public static void ChangeDirection(int value) {
		switch (value) {
			case 0:
				direction = Room.Door.Direction.North;
				break;
			case 1:
				direction = Room.Door.Direction.South;
				break;
			case 2:
				direction = Room.Door.Direction.East;
				break;
			case 3:
				direction = Room.Door.Direction.West;
				break;
			default:
				direction = Room.Door.Direction.StartDir;
				break;
		}
		
		if (changeRoomTimer > RoomChangeBuffer) {
			changeRoomTimer = 0;

			dungeon.ChangeActiveRoom(dungeon.ActiveRoom.GetNeighbor(direction));
		} else {
			return;
		}
		GD.Print(direction);
	}
	
	public static double changeRoomTimer = 0;


	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
		if (dungeon == null) {

			dungeon = new Dungeon(this, 2);

		}
	}
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		
		changeRoomTimer += delta;
		if (Input.IsActionJustPressed("PrimaryFire")) {
			GD.Print(dungeon.ActiveRoom.Self.GetInstanceId());
		}
	}

}
