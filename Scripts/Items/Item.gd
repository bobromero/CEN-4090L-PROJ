extends Resource


class_name Item

enum ItemType {Weapon, Health, Buff, Currency}

@export var name: String = ""
@export var type: ItemType = ItemType.Weapon

func OnPickup(player: Player):
	pass

func Use(player: Player):
	player.RemoveFromInventory()
	pass
