using Godot;
using System;
using System.Collections.Generic;


public partial class Room:TileMapLayer
{
	[Export]
	public Vector2[] Doors;
	public TileMapLayer layer;



	public Room(TileMapLayer _layer) {
		layer = _layer;
	}
}
