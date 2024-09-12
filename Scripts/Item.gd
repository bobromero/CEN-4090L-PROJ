extends Resource


class_name Item

enum ItemType {Weapon, Health, Buff}

@export var name: String = ""
@export var type: ItemType = ItemType.Weapon
