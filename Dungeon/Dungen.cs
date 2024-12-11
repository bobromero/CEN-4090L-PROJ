using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using static Dungen.Room;

public partial class Dungen : Node2D {
	
	public class Dungeon {
		public String startRooms = "res://Prefabs/Rooms/StartRooms/";

		public String commonRooms = "res://Prefabs/Rooms/CommonRooms/";

		public String lootRooms = "res://Prefabs/Rooms/LootRooms/";

		public String bossRooms = "res://Prefabs/Rooms/BossRooms/";

		public String GetRoomPath(Room.RoomType type) {

			Random rand = new Random();


			String path = "";

			switch (type) {
				case Room.RoomType.Common:
					path = commonRooms;
					break;
				case Room.RoomType.Loot:
					path = lootRooms;
					break;
				case Room.RoomType.Boss:
					path = bossRooms;
					break;
				case Room.RoomType.Start:
					path = startRooms;
					break;
				default:
					break;
			}
			//GD.Print("spawning " + type.ToString());

			var dir = DirAccess.Open(path);

			var files = dir.GetFiles();
			
			path += files[rand.Next(files.Length)];
			//GD.Print(dir.GetFiles().Length);

			return path;
		}

		//Room StartRoom;
		public Room ActiveRoom;

		private bool hasBoss = false;
		private Node HostNode;

		public Dictionary<Vector2I, Room> RoomGraph = new Dictionary<Vector2I, Room>();
		public Dictionary<Vector2I, Room.RoomType> RoomTypeGraph = new Dictionary<Vector2I, Room.RoomType>();		
		//public HashSet<Vector2I> visitedRooms = new HashSet<Vector2I>();

		//public int MaxDepth; // how long before force terminating a path
		public int MainPathLength;
		public float SidePathChance;
		public int SidePathLength;
		public int SidePathLengthVariance;

		public Dungeon(Node host, int mainLength, float sideChance, int sideLength, int sideVariance) {
			HostNode = host;
			MainPathLength = mainLength;
			SidePathChance = sideChance;
			SidePathLength = sideLength;
			SidePathLengthVariance = sideVariance;
		}

		// possibly make it pick rooms first and place them into RoomGraph

		public void DecideRooms() {
			//create dungeon based on rules like start at 0,0 go in 1 direction
			//to create a path to the boss and then randomly decide
			//to create a new branch for extra loot rooms

			RoomTypeGraph.Add(Vector2I.Zero, RoomType.Start);

			//generate y rooms starting with a start room and having a mix of loot and common rooms and ending with a boss room
			//for each available door in each room
			//have a x% chance to spawn a side path (so the % chance * 2 per room is the number of side paths)
			//the side path lasts between a certain range following a similar generation to the main path, only shorter and ending with a loot room
			//may need a way to tell the player where the boss is, but maybe not

			DecideMainPath();

		}

		private void DecideSidePaths(Vector2I currentRoom, Door.Direction dir) {
			//random chance per good direction
			Random rand = new Random();

			if (rand.NextDouble() < SidePathChance) {
                var plusMinus = rand.Next(2) == 0 ? 1 : -1;
                var variance = rand.Next(SidePathLengthVariance) * plusMinus;
                MakePath(currentRoom, SidePathLength + variance, dir, false);
            }
		}

		private List<Door.Direction> GetBadDirections(Vector2I currentRoom, Door.Direction originalDirection) {
			var badDirections = new List<Door.Direction>() { originalDirection };

			if (originalDirection == Door.Direction.Missing) {
				badDirections.Remove(Door.Direction.Missing);
			}

			for (var j = 0; j < 4; j++) {
				var direction = Door.IntToDirection(j);
				var location = currentRoom + Door.DirectionToVector2I(direction);

				if (RoomTypeGraph.ContainsKey(location) && direction != originalDirection) {
					badDirections.Add(direction);
				}
			}
			return badDirections;
		}

		private void MakePath(Vector2I currentRoom, int pathLength, Door.Direction originalDirection, bool isMain) {
			for (int i = 0; i < pathLength; i++)
			{
                foreach (var item in RoomTypeGraph)
                {
					//GD.Print(item);
                }
                var badDirections = GetBadDirections(currentRoom, originalDirection);


				//pick and assign room
				//GD.Print((isMain ? " Main Path " : " Side Path ") + currentRoom);
				var randDirection = Door.GetRandomDirection(badDirections);

				if (randDirection == Door.Direction.Missing) {
					currentRoom += Door.DirectionToVector2I(Door.FlipDirection(originalDirection));
					continue;
				}

				Random rand = new Random();

				var roomPos = currentRoom + Door.DirectionToVector2I(randDirection);

				if (isMain && i == MainPathLength - 1) {
					GD.Print("spawned boss");
					RoomTypeGraph.Add(roomPos, RoomType.Boss);
					return;
				}

				var isLoot = rand.Next(4) == 0;

				if (isLoot) {
					RoomTypeGraph.Add(roomPos, RoomType.Loot);
					GD.Print("spawned loot");
				} else {
					RoomTypeGraph.Add(roomPos, RoomType.Common);
				}


				//generate side paths
				if (isMain) {
					badDirections.Add(randDirection);

					DecideSidePaths(currentRoom, Door.GetRandomDirection(badDirections));
				}

				currentRoom = roomPos;
				//GD.Print("current room: " + currentRoom + (isMain ? " Main Path" : " Side Path"));
			}


			//return badDirections;
		}

		private void DecideMainPath() {
			var currentRoom = Vector2I.Zero;
			var mainPathDirection = Door.GetRandomDirection();

			MakePath(currentRoom, MainPathLength, Door.Direction.Missing, true);
		}

		public void FillInRooms() {
			//iterate through room graph and make each room based on the type assigned

			foreach (var room in RoomTypeGraph) {
				Room newRoom = MakeRoom(room.Key, room.Value);

				RoomGraph.Add(room.Key, newRoom);
				newRoom.SetRoomActive(false);
				newRoom.ToggleEntites(false);
			}
		}

		private Room MakeRoom(Vector2I graphPos, RoomType type) {

			var path = GetRoomPath(type);

			RandomNumberGenerator rng = new RandomNumberGenerator();
			var scene = (TileMapLayer)GD.Load<PackedScene>(path).Instantiate();
			scene.Modulate = Color.Color8((byte)(rng.Randi() % 255), (byte)(rng.Randi() % 255), (byte)(rng.Randi() % 255));

			HostNode.AddChild(scene);

			return new Room(scene, graphPos);
		}

		public void CreateStartRoom() {
			TileMapLayer Layer = (TileMapLayer)GD.Load<PackedScene>(GetRoomPath(RoomType.Start)).Instantiate();
			HostNode.AddChild(Layer);

			Room room = new Room(Layer, new Vector2I(0, 0));
			ActiveRoom = room;
			RoomGraph.Add(new Vector2I(0, 0), room);
			room.visited = true;

			room.SetRoomActive(false);
		}

		public bool RoomExists(Room.Door.Direction direction) {
			return RoomGraph.ContainsKey(Room.Door.DirectionToVector2I(direction) + ActiveRoom.id);
		}

		public void ChangeActiveRoom(Room.Door.Direction direction) {
			var coords = ActiveRoom.id + Room.Door.DirectionToVector2I(direction);

			if (ActiveRoom == null) 
				coords = new Vector2I(0,0);

			ChangeActiveRoom(coords);

		}
		public void ChangeActiveRoom(Vector2I roomCoords) {
			//disable all rooms

			foreach (var room in RoomGraph) {
				room.Value.SetRoomActive(false);
			}

			//assign active room

			ActiveRoom = RoomGraph[roomCoords];

			//enable correct room

			ActiveRoom.SetRoomActive(true);
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

			public static Direction GetRandomDirection(List<Direction> toIgnore = null) {
				List<Direction> directions = new List<Direction>() { Direction.North, Direction.South, Direction.East, Direction.West};

				if (toIgnore != null) {
					foreach (var direction in toIgnore) {
						if (directions.Contains(direction)) {
							directions.Remove(direction);
						}
					}
				}

				//GD.Print(directions.Count);

				Random rand	= new Random();
				
				var size = directions.Count;
				//GD.Print(directions.Count);

				if (size == 0) {
					return Direction.Missing;
				}

				return directions.ToArray()[rand.Next(size)];
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

			public static Direction Vector2IToDirection(Vector2I input) {
				if (input == new Vector2I(0,1)) {
					return Direction.North;
				} 
				else if (input == new Vector2I(0,-1)) {
					return Direction.South;
				} 
				else if (input == new Vector2I(1, 0)) {
					return Direction.East;
				} 
				else if (input == new Vector2I(-1, 0)) {
					return Direction.West;
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

			public Node2D blocker;
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
				blocked = enabled;
				blocker.Visible = enabled;
				blocker.ProcessMode = enabled ? ProcessModeEnum.Always : ProcessModeEnum.Disabled;
			}
		}
		public Node2D Self;
		public Vector2I id;
		

		public Dictionary<Door.Direction, Door> doors;
		public HashSet<Door.Direction> lockedDoors;


		public bool visited = false;

		public void UnLockRoom() {
			foreach(var door in doors) {
				if (!lockedDoors.Contains(door.Key)) {
					door.Value.IsBlocked = false;
				}
			}
		}

		public void SetRoomActive(bool value) {

			// taverse and enable/disable each node for all children of the room.self node
			foreach (Node2D child in Self.GetChildren())
			{
				if (child.Name == "Entities") {
					continue;
				}
				UpdateAllChildren(child, value);
			}
			ProcessModeEnum procMode = (value ? ProcessModeEnum.Always : ProcessModeEnum.Disabled);
			Self.Visible = value;
			(Self as TileMapLayer).Enabled = value;
			Self.ProcessMode = procMode;
			Self.SetProcess(value);

			UnLockRoom();
		}

		private void UpdateAllChildren(Node2D node, bool value) {
			foreach (Node2D child in node.GetChildren()) {
				UpdateAllChildren(child, value);
			}
			ProcessModeEnum procMode = (value ? ProcessModeEnum.Always : ProcessModeEnum.Disabled);
			node.Visible = value;
			node.ProcessMode = procMode;
			node.SetProcess(value);
		}

		public Room(Node2D self, Vector2I pos) {
			Self = self;
			id = pos;
			doors = GetDoors(self);
			lockedDoors = new HashSet<Door.Direction>();
		}

		public void ToggleEntites(bool value) {
			(Self.FindChild("Entities") as Node2D).Visible = value;
		}

		public void LockDoors() {
			foreach (var door in doors)
			{
				door.Value.IsBlocked = true;
			}
		}

		public void UpdateDoors() {
			UnLockRoom();
			foreach (var door in doors) {

				Vector2I Neighbor = id + Door.DirectionToVector2I(door.Key);

				if (!dungeon.RoomGraph.ContainsKey(Neighbor)) {
					lockedDoors.Add(door.Key);
				}

				door.Value.IsBlocked = lockedDoors.Contains(door.Key);
				
			}
		}

		private Dictionary<Door.Direction, Door> GetDoors(Node Scene) {
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

				var blocker = input[i].GetChild<Node2D>(1);

				Door door = new Door (dir, _offset, doorNode, blocker);

				result.Add(dir, door);
			}
			return result;
		}

		//public void GetNeighbors() {
		//	foreach (var door in doors) {
		//		var dir = Door.DirectionToVector2I
		//		Neighbors.Add();
		//	}
		//	dungeon.RoomGraph
		//}
		
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

	public static void WalkedIn() {
		if (!dungeon.ActiveRoom.visited) {
			dungeon.ActiveRoom.LockDoors();
			dungeon.ActiveRoom.ToggleEntites(true);
			dungeon.ActiveRoom.visited = true;
		}
	}

	public static void OpenRoomCondition() {
		dungeon.ActiveRoom.UpdateDoors();
	}
	
	public static double changeRoomTimer = 0;


	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
		if (dungeon == null) {
			dungeon = new Dungeon(this, 8, .0f, 3, 1);
			dungeon.DecideRooms();
			dungeon.FillInRooms();

			dungeon.ChangeActiveRoom(new Vector2I(0,0));

			dungeon.ActiveRoom.UpdateDoors();
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
