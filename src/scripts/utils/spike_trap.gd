extends Node2D

static var last_spike_x = 500
static var spike_instances = []
var spike_distance = 1200
var x_variation = 300

func setup_custom_spike():
	scale = Vector2.ONE
	var vp_size = get_viewport_rect().size

	var random_y = randf_range(vp_size.y * 0.5, vp_size.y * 0.9)  # bottom half of viewport
	var random_x_offset = randf_range(-x_variation, x_variation)
	var next_pos = Vector2(last_spike_x + spike_distance + random_x_offset, random_y)
	global_position = next_pos
	last_spike_x = global_position.x

	spike_instances.append(self)
	cleanup_old_spikes()

func cleanup_old_spikes():
	while spike_instances.size() > 600:
		var old_spike = spike_instances.pop_front()
		if is_instance_valid(old_spike):
			old_spike.queue_free()

func _exit_tree():
	var index = spike_instances.find(self)
	if index != -1:
		spike_instances.remove_at(index)
