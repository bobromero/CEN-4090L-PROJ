using Godot;
using System;
using System.Collections.Generic;

public partial class Dungen : TileMapLayer
{
	public class Cell
	{
		/// <summary>
		/// cell position in the world
		/// </summary>
		public Vector2I Position;
		/// <summary>
		/// position of cell used from tilemap
		/// </summary>
		public Vector2I TileMapCell;
		public int TileSetSource;

		private Cell() {
		}
		public Cell(Vector2I _position, Vector2I _tileMapCell, int _tileSetSource = 0) {
			Position = _position;
			TileMapCell = _tileMapCell;
			TileSetSource = _tileSetSource;
		}
	}
	public class Room
	{
		/// <summary>
		/// global cell start position
		/// </summary>
		Vector2I startCell;
		private Cell[][] cells;
		/// <summary>
		/// local map of cells in room
		/// </summary>
		public Cell[][] Cells {
			get { return cells; }
			private set { }
		}


		int height;
		int width;

		private Room() {
		}

		public Room(Vector2I _startCell, Cell[][] _cells, int _height, int _width)
		{
			startCell = _startCell;
			cells = _cells;
			height = _height;
			width = _width;
		}
		public Room(Vector2I _startCell,int _height, int _width)
		{
			height = _height; 
			width = _width;
			cells = new Cell[height][];
			for (int i = 0; i < height; i++) {
				cells[i] = new Cell[width];
			}
			startCell = _startCell;
        }


	}
	



	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		Room room = new Room(new Vector2I(0,0), 4, 4);

		SetCell(room.Cells[0][0].Position, room.Cells[0][0].TileSetSource, room.Cells[0][0].TileMapCell);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}



}
