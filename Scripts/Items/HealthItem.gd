extends Item

@export var amount: float

func Use(player: Player):
	super(player)
	player.IncreaseHealth(amount)
	print(str("increased health to " , player.health))
