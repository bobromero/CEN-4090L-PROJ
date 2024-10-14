extends Resource


class_name Inventory

@export var Weapon: weapon
@export var nonWeaponItems: Array[Item] = []
static var UID:int = 0

func AddItem(item: Item):
	nonWeaponItems.append(item)
	item.InvId = UID
	UID+=1

func RemoveItem(id: int):
	var toRemove = -1
	for x in nonWeaponItems.size():
		if nonWeaponItems[x].InvId == id:
			toRemove = x
			break
	if toRemove >= 0:
		nonWeaponItems.remove_at(toRemove)
