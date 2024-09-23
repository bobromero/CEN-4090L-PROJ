extends Item


func Use(player: Player):
	super(player)
	player.IncreaseHealth(100)
	print(str("increased health to " , player.health))
	
	
