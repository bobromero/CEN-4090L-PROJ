extends Resource
class_name Room

var startPos : Vector2i

var Dimensions: Vector2i

func _init(_startPos: Vector2i, _dimensions : Vector2i):
	startPos = _startPos
	Dimensions = _dimensions
