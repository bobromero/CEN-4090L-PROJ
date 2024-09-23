extends Item

@export var amount: int

func _on_body_entered(body):
	if body.name == "Player":
		queue_free()

	
	
