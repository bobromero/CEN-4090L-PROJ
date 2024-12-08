using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using static Dungen;

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

		public int MaxDepth; // how long before force terminating a path
		public bool hasBoss = false;
		public Node HostNode;

		public Dictionary<Vector2I, Room> RoomGraph = new Dictionary<Vector2I, Room>();
		//public HashSet<Vector2I> visitedRooms = new HashSet<Vector2I>();

		public Dungeon(Node host, int maxDepth) {
			HostNode = host;
			MaxDepth = maxDepth;

			TileMapLayer Layer = (TileMapLayer)GD.Load<PackedScene>(StartPaths[0]).Instantiate();
			HostNode.AddChild(Layer);


			Room room = new Room(Layer, new Vector2I(0, 0));
			ActiveRoom = room;
			RoomGraph.Add(new Vector2I(0, 0), room);
			room.visited = true;
			//visitedRooms.Add(room.id);
			//room.GenerateNeighbors(this, room.id, null, 0);
		}

		public bool RoomExists(Room.Door.Direction direction) {
			return RoomGraph.ContainsKey(Room.Door.DirectionToVector2I(direction) + ActiveRoom.id);
		}

		public void ChangeActiveRoom(Room.Door.Direction direction) {

			//disable all rooms

			foreach (var room in RoomGraph)
			{
				room.Value.SetRoomActive(false);
			}

			//enable correct room

			ActiveRoom = RoomGraph[ActiveRoom.id + Room.Door.DirectionToVector2I(direction)];
			ActiveRoom.SetRoomActive(true);

			ActiveRoom.visited = true;
		}

		public bool IsInGraph(Vector2I pos) {
			return RoomGraph.ContainsKey(pos);
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

			public static Vector2I DirectionToVector2I(Direction dir) {
				if (dir == Direction.North) {
					return new Vector2I(0, 1);
				} else if (dir == Direction.South) {
					return new Vector2I(0, -1);
				}
				else if (dir == Direction.East) {
					return new Vector2I(1, 0);
				} else if (dir == Direction.West) {
					return new Vector2I(-1, 0);
				}
				return new Vector2I(0, 0);
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
			public Vector2 position; // needed for player teleport

			private Node2D blocker;
			public Node2D self;


			private bool blocked;
			public bool IsBlocked {
				set { 
					SetBlockerEnabled(value);
					blocked = value;
				}
				get {
					return blocked;
				}
			}

			public Door(Direction dir, Vector2 pos, Node2D _self, Node2D block) {
				direction = dir;
				position = pos;
				blocker = block;
				self = _self;
			}

			private void SetBlockerEnabled(bool enabled) {
				blocker.Visible = enabled;
				blocker.ProcessMode = enabled ? ProcessModeEnum.Always : ProcessModeEnum.Disabled;
			}
		}
		public Node2D Self;
		public Vector2I id;
		

		public Dictionary<Door.Direction, Door> doors;
		public HashSet<Door.Direction> lockedDoors;

		private Dictionary<Door.Direction, Vector2I> Neighbors;

		public bool visited = false;

		public void UnLockRoom() {
			foreach(var door in doors) {
				if (!lockedDoors.Contains(door.Key)) {
					door.Value.IsBlocked = false;
				}
			}
		}
		public void SetRoomActive(bool value) {
			ProcessModeEnum procMode = (value ? ProcessModeEnum.Always : ProcessModeEnum.Disabled);
			Self.Visible = value;
			foreach (var child in doors.Values) {
				GD.Print(child.self.Name);
				child.IsBlocked = value;
				child.self.ProcessMode = ProcessModeEnum.Inherit;
				//Self.ProcessMode = procMode;
				//Self.SetProcess(value);
			}
			Self.ProcessMode = procMode;
			Self.SetProcess(value);
			UpdateDoors();
		}

		public Room(Node2D self, Vector2I pos) {
			Self = self;
			id = pos;
			Neighbors = new Dictionary<Door.Direction, Vector2I>();
			doors = GetDoors(self);
			lockedDoors = new HashSet<Door.Direction>();
		}

		public void UpdateDoors() {
			UnLockRoom();
			foreach (var door in doors) {
				if (!visited) {
					door.Value.IsBlocked = true;
					continue;
				}

                if (!dungeon.RoomGraph.ContainsKey(id + Door.DirectionToVector2I(door.Key))) {
					lockedDoors.Add(door.Key);
				}
                door.Value.IsBlocked = lockedDoors.Contains(door.Key);
				
			}
		}

		public Dictionary<Door.Direction, Door> GetDoors(Node Scene) {
			Node[] input = Scene.FindChild("Doors").GetChildren(true).ToArray(); // all of the areas only

			Dictionary<Door.Direction, Door> result = new Dictionary<Door.Direction, Door>();

			for (int i = 0; i < input.Count(); i++)
			{
				//GD.Print(input[i].Name);
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
				var doorNode = input[i].GetChild<Node2D>(0);

				var _offset = doorNode.GlobalPosition;

				var blocker = input[i].GetChild<Node2D>(1).GetChild<Node2D>(0);

				Door door = new Door (dir, _offset, doorNode, blocker);

				result.Add(dir, door);
			}
			return result;
		}
		
		public void GenerateNeighbors(Dungeon d, Vector2I ParentRoom, Door connectedDoor, int depth) {
			if (connectedDoor == null) { 
				connectedDoor = new Door(Door.Direction.Missing, new Vector2(0,0), null,null);
			}
			var ParentDir = Door.FlipDirection(connectedDoor.direction);

			Neighbors[ParentDir] = ParentRoom;

			if (depth >= d.MaxDepth) {
				
				return;
			}

			for (int i = 0; i < doors.Count(); i++) {
				Door workingNeighbor = doors[Door.IntToDirection(i)];

				if (ParentDir == workingNeighbor.direction) {
					//GD.Print("skipping " + workingNeighbor + " from " + ParentRoom.id);
					continue;
				}

				var newPos = id + Door.DirectionToVector2I(workingNeighbor.direction);

				if (!d.RoomGraph.ContainsKey(newPos)) {
					//GD.Print("spawning " + workingNeighbor + " from " + ParentRoom.id);

					Room room = MakeRoom(d, newPos, depth);
					Neighbors[workingNeighbor.direction] = room.id;
					d.RoomGraph.Add(newPos, room);

					room.SetRoomActive(false);
					room.GenerateNeighbors(d, room.id, workingNeighbor, depth + 1);
				} else {
					//GD.Print("skipping " + workingNeighbor + " from " + ParentRoom.id + " room already exists");
					//Door.Direction flippedDir = Door.FlipDirection(workingNeighbor.direction);
					//d.RoomGraph[newPos].doors[flippedDir].IsBlocked = false;
				}

			}
		}


		private Room MakeRoom(Dungeon d, Vector2I graphPos, int depth) {
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
					//GD.Print("Spawning Common");
					break;
				case RoomType.Loot:
					path = d.LootPaths[rand.Next(0, d.LootPaths.Count())];
					//GD.Print("Spawning Loot");
					break;
				case RoomType.Boss:
					path = d.BossPaths[rand.Next(0, d.BossPaths.Count())];
					//GD.Print("Spawning Boss");
					break;
				default:
					break;
			}

			RandomNumberGenerator rng = new RandomNumberGenerator();
			var scene = (TileMapLayer)GD.Load<PackedScene>(path).Instantiate();
			scene.Modulate = Color.Color8((byte)(rng.Randi()%255), (byte)(rng.Randi() % 255), (byte)(rng.Randi() % 255));
			
			d.HostNode.AddChild(scene);

			return new Room(scene, graphPos);
		}

		
		public Room GetNeighbor(Door.Direction direction) {
			if (Neighbors == null) {
				GD.Print("Somthing has gone terribly wrong");
				return this;
			}
			return dungeon.RoomGraph[Neighbors[direction]];
		}
	}


	List<Room> rooms = new List<Room>();

	public static Dungeon dungeon;

	public static double RoomChangeBuffer = 2;

	public static void ChangeDirection(int value, GodotObject player) {
		if (changeRoomTimer < RoomChangeBuffer) {
			return;
		} else {
			changeRoomTimer = 0;
			Room.Door.Direction direction = Room.Door.IntToDirection(value);

			if (dungeon.RoomExists(direction)) {
				dungeon.ChangeActiveRoom(direction);

				//GD.Print("Touched " + Room.Door.IntToDirection(value) + " door, coming out the " + Room.Door.FlipDirection(direction));
				player.Call("changePos", dungeon.ActiveRoom.doors[Room.Door.FlipDirection(direction)].position);
			}
			
		}
	}
	
	public static double changeRoomTimer = 0;


	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
		if (dungeon == null) {

			dungeon = new Dungeon(this, 2);
            dungeon.ActiveRoom.GenerateNeighbors(dungeon, dungeon.ActiveRoom.id, null, 0);
        }
    }
    // Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		
		changeRoomTimer += delta;
		if (Input.IsActionJustPressed("PrimaryFire")) {
			dungeon.ActiveRoom.UpdateDoors();
		}

	}

}
