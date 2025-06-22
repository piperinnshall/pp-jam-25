extends StaticBody2D

@export var spike_count: int = 200
@export var spacing: int = 27

func setup(ready: bool):
	if ready:
		var vp_size = get_viewport_rect().size
		global_position = Vector2(vp_size.x * 0.5, vp_size.y * 0.5)
		scale = Vector2(1, 1)
