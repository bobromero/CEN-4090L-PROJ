extends Item

@export var value = 10;

func OnPickup(player: Player):
	Use(player)

func Use(player: Player):
	player.addScore(value)
	super(player)
	
	
