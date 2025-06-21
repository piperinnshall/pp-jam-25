extends CharacterBody2D

@export var speed: float
@export var gravity: float

var hook_pos: Vector2 = Vector2()
var hooked: bool

var rope_len: float = 500
var rope_len_current: float

func _ready() -> void:
	rope_len_current = rope_len 

func _physics_process(delta: float) -> void:
	hook_process()
	gravity_process()
	if hooked:
		swing(delta)
		velocity *= 0.975 # Speed of swing
		move_and_slide()
		gravity_process()
	move(delta)
	move_and_slide()
	queue_redraw()

func gravity_process() -> void:
	velocity.y += gravity

func _draw() -> void:
	var pos = global_position
	if hooked:
		draw_line(Vector2(0,0), to_local(hook_pos), Color(1,1,1), 3, true)
	else:
		return
	for raycast: RayCast2D in $Raycast.get_children():
		if raycast.is_colliding():
			var collide_point = raycast.get_collision_point()
			if pos.distance_to(collide_point) < rope_len:
				draw_line(Vector2(0,0), to_local(hook_pos), Color(0,0,0), 3, true)
				break

func hook_process() -> void:
	$Raycast.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("left_click"):
		hook_pos = get_hook_pos()
		if hook_pos:
			hooked = true
			rope_len_current = global_position.distance_to(hook_pos)
	if Input.is_action_just_released("left_click") and hooked:
		hooked = false
	return Vector2()

func get_hook_pos() -> Vector2:
	for raycast: RayCast2D in $Raycast.get_children():
		if raycast.is_colliding():
			return raycast.get_collision_point()
	return Vector2()

func swing(delta: float) -> void:
	var radius: Vector2 = global_position - hook_pos
	if velocity.length() < 0.01 or radius.length() < 10: 
		return
	var angle: float = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var rad_velocity: float = cos(angle) * velocity.length()
	velocity += radius.normalized() * -rad_velocity
	if global_position.distance_to(hook_pos) > rope_len_current:
		global_position = hook_pos + radius.normalized() * rope_len_current
	#velocity += (hook_pos - global_position).normalized() * 7000 * delta

func move(_delta: float) -> void:
	if Input.is_action_pressed("key_d"):
		velocity.x += speed
	elif Input.is_action_pressed("key_a"):
		velocity.x -= speed
	else:
		velocity.x = 0
