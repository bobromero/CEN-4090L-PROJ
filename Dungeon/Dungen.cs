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
			room.GenerateNeighbors(this, room, Room.Door.Direction.Missing, 0);
		}

		public void ChangeActiveRoom(Room newActiveRoom, Room.Door.Direction dir) {
			ActiveRoom.ChangeRoomActive(false);
			ActiveRoom = newActiveRoom;
			ActiveRoom.ChangeRoomActive(true);
			//ActiveRoom.doors[dir].position;
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
				Missing
			}

			public static Direction IntToDirection(int number) {
				switch (number) {
					case 0:
						return Direction.North;
					case 1:
						return Direction.South;
					case 2:
						return Direction.East;
					case 3:
						return Direction.West;
					default:
						break;
				}
				return Direction.Missing;
			}

            public static Direction FlipDirection(Direction ori) {
				if (ori == Direction.North) {
					return Direction.South;
				} else if (ori == Direction.South) {
					return Direction.North;
				}
                if (ori == Direction.East) {
                    return Direction.West;
                } else if (ori == Direction.West) {
                    return Direction.East;
                }
				return Direction.Missing;
			}

			public Direction direction;
            public Vector2 position;
        }
		public Node2D Self;
		private int id;
		

		public Dictionary<Door.Direction, Door> doors;

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
			Neighbors = new Dictionary<Door.Direction, Room>();
			doors = GetDoors(self);
		}

		public Dictionary<Door.Direction, Door> GetDoors(Node Scene) {
			Node[] input = Scene.GetChildren().Where(r => r.GetChild(0).Name.ToString().Contains("Door")).ToArray();
            Dictionary<Door.Direction, Door> result = new Dictionary<Door.Direction, Door>();

			for (int i = 0; i < input.Count(); i++)
			{
				Door.Direction dir = Door.Direction.North;

				switch (input[i].Name.ToString()[0]) {
					case 'N':
                        dir = Door.Direction.North;
						break;
					case 'E':
                        dir = Door.Direction.East;
						break;
					case 'S':
                        dir = Door.Direction.South;
						break;
					case 'W':
                        dir = Door.Direction.West;
						break;
					default:
						break;
				}
				var _offset = input[i].GetChild<Node2D>(0).GlobalPosition;
				GD.Print(input[i].GetChild<Node2D>(0).Name);
				result.Add(dir, new Door {
                    direction = dir,
                    position = _offset
                });
			}
			return result;
		}
		
		public void GenerateNeighbors(Dungeon d, Room ParentRoom, Door.Direction connectedDir, int depth) {
			Neighbors[Door.FlipDirection(connectedDir)] = ParentRoom;
			if (depth >= d.MaxDepth) {
				return;
			}

			for (int i = 0; i < doors.Count(); i++) {
				
				if (connectedDir == Door.IntToDirection(i))
				{
                    //ParentRoom.Self.Position = Neighbors[workingNeighbor]
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
			if (Neighbors == null) {
                GD.Print("Somthing has gone terribly wrong");
                return this;
			}
			return Neighbors[direction];
		}
	}


	List<Room> rooms = new List<Room>();

	public static Dungeon dungeon;

	private static Room.Door.Direction direction = Room.Door.Direction.Missing; //used as an interface between godot and c#

	public static double RoomChangeBuffer = 2;

	public static void ChangeDirection(int value, GodotObject player) {

		
		
		if (changeRoomTimer < RoomChangeBuffer) {
			return;
		} else {
            changeRoomTimer = 0;
			direction = Room.Door.IntToDirection(value);
            dungeon.ChangeActiveRoom(dungeon.ActiveRoom.GetNeighbor(direction), direction);
			GD.Print("Touched " + Room.Door.IntToDirection(value) + " door, coming out the " + Room.Door.FlipDirection(direction));
            player.Call("changePos", dungeon.ActiveRoom.doors[Room.Door.FlipDirection(direction)].position);
        }
	}
	
	public static double changeRoomTimer = 0;


	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
		if (dungeon == null) {

			dungeon = new Dungeon(this, 1);

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
