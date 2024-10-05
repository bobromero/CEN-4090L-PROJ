extends Resource


class_name Item

enum ItemType {Weapon, Health, Buff, Currency}

@export var name: String = ""
@export var type: ItemType = ItemType.Weapon
@export var InvId: int = -1 # -1 means not in an inventory

func OnPickup(player: Player):
	pass

func Use(player: Player):
	pass
