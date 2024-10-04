extends Resource


class_name Item

enum ItemType {Weapon, Health, Buff, Currency}

@export var name: String = ""
@export var type: ItemType = ItemType.Weapon

func Use(player: Player):
	pass
