extends RopeCollisionStrategyInterface

@export var max_collision_time: float = 1
@export_enum("RESET_TIMER", "KEEP_TIMER", "COUNT_UP") var collision_exit_behaviour = "COUNT_UP"

var _count_down_timer: Timer
var _count_up_timer: Timer
var _rope: Rope

var _num_collisions: int = 0

func _ready() -> void:
	_count_down_timer = Timer.new()
	_count_down_timer.timeout.connect(_on_timer_timeout)
	add_child(_count_down_timer)
	
	_count_up_timer = Timer.new()
	_count_up_timer.wait_time = max_collision_time
	add_child(_count_up_timer)
	
	_count_down_timer.start(max_collision_time)
	_count_down_timer.paused = true

func on_collision_entered(rope: Rope, body: Node3D) -> void:
	
	# not very pretty, but we need to get (and keep) reference to the rope,
	# without requiring an external initialization of the collision strategy
	_rope = rope
			
	_num_collisions += 1
	if _num_collisions != 1:
		return
	
	if collision_exit_behaviour == "COUNT_UP" and _count_down_timer.paused:
		var time_left = _count_down_timer.time_left + max_collision_time - _count_up_timer.time_left
		time_left = min(max_collision_time, time_left)
		_count_down_timer.start(time_left)
		
		_count_up_timer.stop()
	
	_count_down_timer.paused = false

func on_collision_exited(rope: Rope, body: Node3D) -> void:
	_num_collisions -= 1
	if _num_collisions > 0:
		return
		
	_count_down_timer.paused = true
	
	match collision_exit_behaviour:
		"RESET_TIMER":
			_count_down_timer.start(max_collision_time)
		"KEEP_TIMER":
			pass
		"COUNT_UP":
			_count_up_timer.start(max_collision_time)
	
func _on_timer_timeout() -> void:
	_rope.finish()
	
