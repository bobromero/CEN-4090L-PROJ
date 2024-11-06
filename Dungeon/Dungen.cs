using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Dungen : Node2D {
	List<Room> rooms = new List<Room>();
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		TileMapLayer Layer = (TileMapLayer)GD.Load<PackedScene>("res://Prefabs/Rooms/room0.tscn").Instantiate();
        AddChild(Layer);
		Room room = new Room (Layer);
		rooms.Add(room);
    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionJustPressed("PrimaryFire")) {
			//rooms.FirstOrDefault(). spawn the room
            TileMapLayer scene = (TileMapLayer) GD.Load<PackedScene>("res://Prefabs/Rooms/room1.tscn").Instantiate();
			AddChild(scene);
		}
	}

	/**
	 *	I want to spread rooms out if they overlap
	 *	whats the best way of doing this
	 *	
	 *	1. look into trees
	 *	put rooms into tree
	 *	traverse tree and make sure they don't touch or combine properly
	 *	pros:
	 *		- more unique
	 *		- more interesting
	 *	cons: 
	 *		- harder
	 *		- may not finish
	 *	
	 *	2. have some sort of grid system
	 *	spawn rooms apart a certain amount and connect them via hallways
	 *	pros: 
	 *		- easier
	 *		- less could go wrong
	 *	cons: 
	 *		- less diversity
	 *		- more boring
	 *	
	 *	3. spawn a room, spawn another room and push it until it doesn't overlap with any other room
	 *	repeat
	 *	
	 *	4. To have control over the layout a bit, I want to create a series of rooms connected "edge to edge" 
	 *	where there is a gap and potential offset fixed by a hallway
	 *	
	 *	******5. neon abyss style dungeons, each room locks you in but you still have variety in layout based on spawning scenes
	 *	rooms are a new layer and can 
	 *	
	 */


}
