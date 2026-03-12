@tool
class_name DayNightCycle
extends Node3D

signal time_period_changed(current: TimePeriod)
signal day_changed(current: int)

@export var debug_log: bool = false

## Duration in physics process ticks from beginning of day zero. Is the source of truth.
@export var tick_count: int = 0:
	set(value):
		tick_count = max(value, 0)
		_is_updating = true

		current_day = get_days_since_start()
		day_seconds = get_relative_seconds()
		time_period = timestamp_to_time_period(get_elapsed_time())

		_is_updating = false

# is negative by default to force setter call on load.
@export var current_day: int = -1:
	set(value):
		if current_day == value:
			return

		current_day = max(value, 0)
		day_changed.emit(current_day)
		if debug_log:
			print("Day ", current_day, " started")

		if not _is_updating:
			tick_count = _get_tick_count(current_day, day_seconds)

# has custom export_range
var day_seconds: float = 0.0:
	set(value):
		const DT: float = 0.001
		day_seconds = clamp(value, 0, day_duration - DT)

		if not _is_updating:
			tick_count = _get_tick_count(current_day, day_seconds)

var day_duration: float

var time_period: TimePeriod:
	set(value):
		if not is_node_ready() or time_period == value:
			return
		time_period = value
		time_period_changed.emit(time_period)
		if debug_log:
			print(time_period.name, " time of day started")

## Times of day that constitute one cycle
var time_periods: Array[TimePeriod] = []

var tps: int = Engine.physics_ticks_per_second

var _is_updating: bool = true


func get_elapsed_time() -> float:
	return float(tick_count) / tps


func _get_tick_count(day: int, seconds: float) -> int:
	return floor(day * day_duration + seconds) * tps


func get_days_since_start() -> int:
	return floor(get_elapsed_time() / day_duration)


## Converts get_elapsed_time to seconds relative to the beginning of the current day.
func get_relative_seconds() -> float:
	return get_elapsed_time() - int(get_days_since_start() * day_duration)


func timestamp_to_time_period(_timestamp: float) -> TimePeriod:
	if time_periods.is_empty():
		return null
	var time = get_relative_seconds()
	for period in time_periods:
		time -= period.duration
		if time <= 0:
			return period
	return time_periods.back()


func update_day_duration() -> void:
	day_duration = time_periods.reduce(func(a, t): return a + t.duration, 0.0)

	if debug_log:
		print("New day duration: ", day_duration)


func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint() and day_duration > 0.0:
		tick_count += 1


func _init() -> void:
	add_to_group("day_night_cycle")


func _ready() -> void:
	_is_updating = false
	time_period = timestamp_to_time_period(get_elapsed_time())
	child_exiting_tree.connect(_on_child_exiting_tree)
	child_order_changed.connect(_update_time_periods)
	_update_time_periods()


func _on_child_exiting_tree(node: Node):
	if node is not TimePeriod:
		return
	if node.duration_changed.is_connected(update_day_duration):
		node.duration_changed.disconnect(update_day_duration)


func _update_time_periods():
	time_periods.assign(get_children().filter(func(c): return c is TimePeriod))
	for period in time_periods:
		if not period.duration_changed.is_connected(update_day_duration):
			period.duration_changed.connect(update_day_duration)

	update_day_duration()
	update_configuration_warnings()
	if debug_log:
		print("New time periods: ", time_periods)


func _get_configuration_warnings() -> PackedStringArray:
	if time_periods.filter(func(t): return t != null).is_empty():
		return [
			"""Time periods array is empty. \
			This node will not work correctly without at least one time period child."""
		]
	if day_duration <= 0.0:
		return ["Ensure day duration is longer than 0."]
	return []


func _get_property_list() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var prop_list = get_script().get_script_property_list()

	var day_seconds_prop = prop_list[prop_list.find_custom(
		func(p): return p["name"] == "day_seconds"
	)]
	day_seconds_prop["usage"] |= PROPERTY_USAGE_DEFAULT
	day_seconds_prop["hint"] |= PROPERTY_HINT_RANGE
	day_seconds_prop["hint_string"] = "%s,%s" % [0.0, day_duration]
	result.push_back(day_seconds_prop)

	return result
