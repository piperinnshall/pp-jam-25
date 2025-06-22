extends StaticBody2D
static var last_platform_x = 0 
static var platform_instances = []
var platform_distance = 700
var x_variation = 100

func setup(first_spawn: bool):
	scale = Vector2.ONE
	var vp_size = get_viewport_rect().size
	
	if first_spawn:
		global_position = Vector2(vp_size.x * 0.5, vp_size.y * 0.25)
		last_platform_x = global_position.x
	else:
		var random_y = randf_range(40, 40 + (vp_size.y * 0.25))
		var random_x_offset = randf_range(-x_variation, x_variation)
		var next_pos = Vector2(last_platform_x + platform_distance + random_x_offset, random_y)
		global_position = next_pos
		last_platform_x = global_position.x
	
	platform_instances.append(self)
	cleanup_old_platforms()

func cleanup_old_platforms():
	while platform_instances.size() > 60:
		var old_platform = platform_instances.pop_front()
		if is_instance_valid(old_platform):
			old_platform.queue_free()

func _exit_tree():
	var index = platform_instances.find(self)
	if index != -1:
		platform_instances.remove_at(index)
