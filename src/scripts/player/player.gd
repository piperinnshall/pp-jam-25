extends RigidBody2D

@export var contacts_reported = 10

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var speed = 10
@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D
@onready var line = $Line2D
@onready var label = $Label
@onready var line_end = hook.get_node("Marker2D")

var hooked = false
var can_hook = true

func _ready():
	label.text = "0 . 0"
	label.modulate = Color.BLACK
	connect("body_entered", Callable(self, "_on_body_entered"))


func _process(delta: float) -> void:
	# print(rad_to_deg(get_angle_to(get_global_mouse_position())))
	camera(delta)
	update_emoticon()
	shoot_input()
	update_line()
	movement()

func camera(delta: float) -> void:
	var cam = $Camera2D
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
	ray_cast_2d.target_position = to_local(get_global_mouse_position())
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		var hook_pos = ray_cast_2d.get_collision_point()
		var collider = ray_cast_2d.get_collider()
		if collider.is_in_group("Hookable"):
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

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Spike"):
		var direction = (global_position - body.global_position).normalized()
		apply_central_impulse(direction * 300)
		can_hook = false
		unhook()
		await get_tree().create_timer(5.0).timeout
		can_hook = true
