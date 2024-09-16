extends Item

@export var amount: int

func Use(player: Player):
	super(player)
	player.addScore(10)

	
	
