using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Dungen : TileMapLayer
{
	public class Cell
	{
		/// <summary>
		/// relative cell position in the room
		/// </summary>
		public Vector2I Position;
        /// <summary>
        /// global cell position in the world
        /// </summary>
        public Vector2I GlobalPosition;
        /// <summary>
        /// position of cell used from tilemap
        /// </summary>
        public Vector2I TileMapCell;
		public int TileSetSource;

		private Cell() {
		}
		public Cell(Vector2I _position, Vector2I _globalPos, Vector2I _tileMapCell, int _tileSetSource = 0) {
			GlobalPosition = _position;
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
		private List<Cell> cells;

		public List<Cell> Doorways;
		public List<Cell> Walls;
		/// <summary>
		/// local map of cells in room
		/// </summary>
		public List<Cell> Cells {
			get { return cells; }
			private set { }
		}


		int height;
		int width;


		public void GenerateDoorways(int minDoorways = 1, int maxDoorways = 4) {
			/* doorways are on
			 * x,y
			0, height/2 - left
			width/2, 0 - top
			width - 1, height/2 - right
			width/2, height - 1 - bottom
			*/

		}


		private void DefineCells(Vector2I _startCell, int _height, int _width) {
            for (int i = 0; i < height; i++)
            {
                for (int j = 0; j < width; j++) {
					var cell = new Cell(new Vector2I(i,j), new Vector2I(i + _startCell.X, j + _startCell.Y), new Vector2I(1, 1));
                    cells.Add(cell);
					if (i == height - 1 || i == 0) {
						cell.TileMapCell = new Vector2I(3,2);
						Walls.Add(cell);
					}else if(j == width - 1 || j == 0) {
                        cell.TileMapCell = new Vector2I(3, 2);
                        Walls.Add(cell);
					}

				}
            }
        }


		private Room() {
		}

		public Room(Vector2I _startCell, List<Cell> _cells, List<Cell> _walls, int _height, int _width)
		{
			startCell = _startCell;
			cells = _cells;
			height = _height;
			width = _width;
			Walls = _walls;
		}
		public Room(Vector2I _startCell,int _height, int _width)
		{
			height = _height; 
			width = _width;
			cells = new List<Cell>();
			Walls = new List<Cell>();
			DefineCells(_startCell, _height, _width);
			startCell = _startCell;
        }


	}
	
	List<Room> rooms = new List<Room>();



	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		rooms.Add(new Room(new Vector2I(0,0), 16, 16));
        foreach (var room in rooms)
        {
            foreach (var cell in room.Cells)
            {
                SetCell(cell.Position, cell.TileSetSource, cell.TileMapCell);
            }

        }

		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}



}
