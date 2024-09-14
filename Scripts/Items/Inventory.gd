extends Resource


class_name Inventory

@export var Weapon: weapon
@export var nonWeaponItems: Array[Item] = []

func AddItem(item: Item):
	nonWeaponItems.append(item)
func RemoveItem(id: int):
	nonWeaponItems.remove_at(id)
