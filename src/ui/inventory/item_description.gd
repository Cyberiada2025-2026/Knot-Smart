@tool
class_name ItemDescription
extends Resource


@export var item_name: String = ""
@export var description: String = ""
## The parent node that represents a collectible item. Acquired using get_parent() method.
var main_node: Node3D
