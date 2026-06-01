extends Control

var player: Node
var health_component: HealthComponent
var max_health: float
var health_bar: Control


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	health_component = player.get_node("HealthComponent")
	health_bar = get_node("missing_health/current_health")
	max_health = health_component.max_health
	health_component.health_decreased.connect(health_changed)
	health_component.health_increased.connect(health_changed)
	health_component.max_health_changed.connect(max_health_changed)


func health_changed() -> void:
	var bar_size: Vector2
	var original_bar_size = get_node("missing_health").get_size()
	bar_size.y = original_bar_size.y
	bar_size.x = (health_component.health / max_health) * original_bar_size.x
	health_bar.set_size(bar_size)


func max_health_changed() -> void:
	max_health = health_component.max_health
