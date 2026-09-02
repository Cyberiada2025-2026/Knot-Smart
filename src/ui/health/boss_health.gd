extends TextureProgressBar

var boss: Node
var health_component: HealthComponent
var max_health: float
var health: float


func _ready() -> void:
	boss = get_parent()
	health_component = boss.get_node("HealthComponent")
	max_health = health_component.max_health
	health = health_component.health
	health_changed()
	health_component.health_decreased.connect(health_changed)
	health_component.health_increased.connect(health_changed)
	health_component.max_health_changed.connect(max_health_changed)


func change_bar_size():
	value = health / max_health * 100


func health_changed():
	health = health_component.health
	change_bar_size()


func max_health_changed():
	max_health = health_component.max_health
	change_bar_size()
