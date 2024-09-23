extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in 10:
		for y in 10:
			print(x,y)
			set_cell(Vector2i(x,y), 0, Vector2i(1,1), 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
