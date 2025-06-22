extends RigidBody2D
@export var contacts_reported = 10
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var speed = 10
@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D
@onready var line = $Line2D
@onready var label = $Label
@onready var score = get_node("/root/World/CanvasLayer/Score")
@onready var health_bar = $HealthBar/HealthCircle
#@onready var line_end = hook.get_node("Marker2D")
var line_end
var shake_time = 0.0
var shake_strength = 0.0


var start_position: Vector2
var total_distance: float = 0.0

var hooked = false
var can_hook = true
var max_health = 100.0
var current_health = 100.0

func _ready():
	$Timer.timeout.connect(_on_Timer_timeout)
	$Timer.start()

	start_position = global_position

	if hook and hook.has_node("Marker2D"):
		line_end = hook.get_node("Marker2D")
	else:
		print("Error: hook is null or doesn't have Marker2D child")
		return

	# Validate all required nodes exist
	if not ray_cast_2d:
		print("Error: RayCast2D node not found")
		return
	if not line:
		print("Error: Line2D node not found")
		return
	if not label:
		print("Error: Label node not found")
		return

	# Check exported variables (these should be assigned in the editor)
	if not hook:
		print("Error: hook StaticBody2D not assigned in editor")
		return
	if not pinjoint:
		print("Error: pinjoint PinJoint2D not assigned in editor")
		return

	# Try to get the line_end marker safely
	if hook.has_node("Marker2D"):
		line_end = hook.get_node("Marker2D")
	else:
		print("Error: Marker2D not found as child of hook")
		return

	# Try to get score and health bar nodes safely
	var world_node = get_tree().get_first_node_in_group("world")
	if world_node:
		score = world_node.get_node_or_null("CanvasLayer/Score")
	if not score:
		print("Warning: Score node not found")

	if has_node("HealthBar/HealthCircle"):
		health_bar = $HealthBar/HealthCircle
	else:
		print("Warning: HealthBar/HealthCircle not found")

	# Initialize UI elements if they exist
	if label:
		label.text = "0 . 0"
		label.modulate = Color.BLACK

	if health_bar:
		health_bar.set_health(current_health, max_health)

	# Connect signals safely
	if has_signal("body_entered"):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:

	if not is_inside_tree():
		return

	camera()
	update_emoticon()
	shoot_input()
	update_line()
	movement()
	update_score(delta)
	apply_camera_shake(delta)

func apply_camera_shake(delta: float) -> void:
	if shake_time > 0:
		shake_time -= delta
		var offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		$Camera2D.offset = offset
	else:
		$Camera2D.offset = Vector2.ZERO

func update_score(delta: float) -> void:
	var distance = global_position.distance_to(start_position)
	var velocity = linear_velocity.length()

	var distance_km = round(distance / 100.0) / 10.0  # 1 decimal place, in "meters" if 1000px = 1m
	var speed_display = round(velocity * 10) / 10.0   # 1 decimal place

	score.text = "Score: %.1fm " % [distance_km]

func camera() -> void:
	var cam = $Camera2D
	cam.global_position.x = global_position.x
	cam.global_position.y = get_viewport().get_visible_rect().size.y / 2

func update_emoticon():
	if Input.is_action_pressed("shoot"):
		label.text = "> . <"
	else:
		label.text = "0 . 0"

func shoot_input():
	if Input.is_action_just_pressed("shoot") and not hooked and can_hook:
		try_hook()
	elif Input.is_action_just_released("shoot") and hooked:
		unhook()

func try_hook():
	# Check if required nodes exist
	if not hook or not is_instance_valid(hook):
		print("Error: hook node is null or invalid")
		return
	if not pinjoint or not is_instance_valid(pinjoint):
		print("Error: pinjoint node is null or invalid")
		return
	if not ray_cast_2d or not is_instance_valid(ray_cast_2d):
		print("Error: ray_cast_2d node is null or invalid")
		return

	ray_cast_2d.target_position = to_local(get_global_mouse_position())
	ray_cast_2d.force_raycast_update()

	if ray_cast_2d.is_colliding():
		var hook_pos = ray_cast_2d.get_collision_point()
		var collider = ray_cast_2d.get_collider()

		if collider and collider.is_in_group("Hookable"):
			hooked = true
			pinjoint.global_position = hook_pos
			hook.global_position = hook_pos
			pinjoint.node_b = get_path_to(hook)
			var direction = hook_pos - global_position
			hook.rotation = direction.angle()

func unhook():
	hooked = false
	pinjoint.node_b = NodePath("")

func update_line():
	line.clear_points()
	if hooked:
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(line_end.global_position))

func movement():
	var grounded = get_contact_count() > 0
	if Input.is_action_pressed("right") and (grounded or hooked):
		apply_central_impulse(Vector2.RIGHT)
	if Input.is_action_pressed("left") and (grounded or hooked):
		apply_central_impulse(Vector2.LEFT)
	if Input.is_action_just_pressed("jump") and grounded:
		apply_central_impulse(Vector2.UP * 100)

func take_damage(amount: float):
	current_health = max(0, current_health - amount)
	health_bar.set_health(current_health, max_health)

	# Check if dead
	if current_health <= 0:
		print("Player died!")
		shake_time = 2.0         # Duration of shake in seconds
		shake_strength = 10.0    # How intense the shake is

		#await get_tree().create_timer(2.0).timeout

		start_death_sequence()
		# Add death logic here

func start_death_sequence():
	# Store reference to scene tree before any potential node removal
	var tree = get_tree()

	# Check if we still have a valid tree reference
	if not tree or not is_inside_tree():
		print("Warning: Cannot start death sequence - node not in tree")
		return

	# Wait for 2 seconds
	await tree.create_timer(1.0).timeout

	# Quit the game
	tree.quit()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Spike"):
		var direction = (global_position - body.global_position).normalized()
		apply_central_impulse(direction * 300)
		can_hook = false
		unhook()
		# Take damage when hitting spikes
		take_damage(20)  # Adjust damage amount as needed
		await get_tree().create_timer(0.3).timeout
		can_hook = true

	if body.is_in_group("Branch"):
		# Heal when touching branches
		heal(15)  # Adjust heal amount as needed
		#body.queue_free()  # Remove the branch after collecting it


func heal(amount: float):
	current_health = min(max_health, current_health + amount)
	health_bar.set_health(current_health, max_health)

func _on_Timer_timeout() -> void:
	var pad_y = 25
	var screen_bottom = get_viewport().get_visible_rect().size.y + pad_y
	if global_position.y > screen_bottom:
		take_damage(20)
