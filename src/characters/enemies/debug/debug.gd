extends Camera3D

@export var interesting: PackedScene
@export var player: PackedScene

var selected = null

func _input(event):
    if event.is_action_pressed("set_player"):
        selected = player
    if event.is_action_pressed("set_interesting"):
        selected = interesting
    if event.is_action_pressed("click"):
        var pos = shoot_ray()
        if pos == null or selected == null:
            print("pos: ", pos)
            print("selected: ", selected)
            return
        spawn_point(selected, pos)
        
func shoot_ray():
    var mouse_pos = get_viewport().get_mouse_position()
    var ray_lenght = 1000
    var from = project_ray_origin(mouse_pos)
    var to = from + project_ray_normal(mouse_pos) * ray_lenght
    var space = get_world_3d().direct_space_state
    var ray_query = PhysicsRayQueryParameters3D.new()
    ray_query.from = from
    ray_query.to = to
    var raycast_result = space.intersect_ray(ray_query)
    if raycast_result.is_empty():
        return null
    else:
        return raycast_result["position"]

func spawn_point(point: PackedScene, pos:Vector3):
    var instance : Node3D = point.instantiate()
    get_parent().add_child(instance)
    instance.global_position = pos
    
