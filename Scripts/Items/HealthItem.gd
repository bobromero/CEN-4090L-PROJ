extends Item

@export var amount: float

func OnPickup(player: Player):
	super(player)
	Use(player)
	

func Use(player: Player):
	super(player)
	player.IncreaseHealth(amount)
	#print(str("increased health to " , player.health))
