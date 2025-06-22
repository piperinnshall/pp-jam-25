extends Control


var current_health: float = 100
var max_health: float = 100
var circle_radius: float = 30
var circle_thickness: float = 4
var health_color: Color = Color.GREEN
var background_color: Color = Color.DARK_GRAY

func _ready():
	modulate.a = 0.4  # Adjust value between 0.0 (invisible) and 1.0 (opaque)
	# Make sure the control node has a size
	custom_minimum_size = Vector2(circle_radius * 2 + 20, circle_radius * 2 + 20)
	# Center the control node
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -custom_minimum_size.x / 2
	offset_right = custom_minimum_size.x / 2
	offset_top = -custom_minimum_size.y / 2
	offset_bottom = custom_minimum_size.y / 2

func _draw():
	var center = size / 2
	
	# Draw background circle (unfilled part)
	draw_arc(center, circle_radius, 0, TAU, 64, background_color, circle_thickness)
	
	# Calculate health percentage and angle
	var health_percentage = current_health / max_health
	var health_angle = health_percentage * TAU
	
	# Change color based on health level
	if health_percentage > 0.6:
		health_color = Color.GREEN
	elif health_percentage > 0.3:
		health_color = Color.YELLOW
	else:
		health_color = Color.RED
	
	# Draw health arc (filled part) - starts from top and goes clockwise
	if health_percentage > 0:
		draw_arc(center, circle_radius, -PI/2, -PI/2 + health_angle, 64, health_color, circle_thickness)

func set_health(new_health: float, new_max_health: float):
	current_health = new_health
	max_health = new_max_health
	queue_redraw()  # Triggers _draw() to be called again

func set_radius(new_radius: float):
	circle_radius = new_radius
	custom_minimum_size = Vector2(circle_radius * 2 + 20, circle_radius * 2 + 20)
	queue_redraw()

func set_thickness(new_thickness: float):
	circle_thickness = new_thickness
	queue_redraw()
