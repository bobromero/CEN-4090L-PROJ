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
		public Vector2I spawnOffset = new Vector2I(0, 0);
        Room StartRoom;
		public int roomCount = 0;
		public int MaxDepth; // how long before force terminating a path
		public bool hasBoss = false;
		public Node Host;

		public Dungeon(Node host, int maxDepth) {
			Host = host;
            MaxDepth = maxDepth;
            TileMapLayer Layer = (TileMapLayer)GD.Load<PackedScene>(StartPaths[0]).Instantiate();
            Host.AddChild(Layer);
            Room room = new Room(Layer, roomCount++, Room.RoomType.Start);
			room.GenerateNeighbor(this, 0);
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
		public RoomType Type;
        public Node Self;
        private int id;
		private IEnumerable<Node> doors;
		public IEnumerable<Node> Doors {
			private set { this.doors = value; }
			get { return this.doors; }
		}
		private List<Room> Neighbors = new List<Room>();
	
		public Room(Node self, int _id, RoomType type) {
            Self = self;
			id = _id;
			Type = type;
			doors = GetDoors(self);
		}

		public IEnumerable<Node> GetDoors(Node Scene) {
			return Scene.GetChildren().Where(r => r.GetChild(0).Name.ToString().Contains("Door"));
        }
        
        public void GenerateNeighbor(Dungeon d, int depth) {
            if (depth > d.MaxDepth) {
                return;
            }
            for (int i = 0; i < doors.Count(); i++) {
                RoomType type;
                
                if (depth > d.MaxDepth-1) {
                    if (d.hasBoss)
                    {
						type = RoomType.Loot;
                        
					} else {
						type = RoomType.Boss;
                        d.hasBoss = true;
                    }
                }
                else
                {
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
                TileMapLayer scene = (TileMapLayer)GD.Load<PackedScene>(path).Instantiate();
                d.Host.AddChild(scene);
                d.spawnOffset += scene.GetUsedRect().Position * 500;
                Room room = new Room(scene, d.roomCount++, type);
                Neighbors.Add(room);

            }
            foreach (var neighbor in Neighbors)
            {
                depth+=1;
                neighbor.GenerateNeighbor(d, depth);
            }

        }

    }


	List<Room> rooms = new List<Room>();

	Dungeon dungeon;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
		dungeon = new Dungeon(this, 4);
    }

	
	int roomCount = 0;
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


}
