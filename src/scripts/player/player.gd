extends CharacterBody2D

var speed: float = 600
var gravity_force: float = 50
var hook_pos: Vector2 = Vector2()
var hooked: bool = false
var rope_len: float = 500
var rope_len_current: float

func _ready() -> void:
	rope_len_current = rope_len 

func _physics_process(delta: float) -> void:
	gravity_process(delta)
	hook_process()
	queue_redraw()
	
	if hooked:
		swing(delta)
		velocity *= 0.975
	else:
		move(delta)
	
	move_and_slide()

func gravity_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity_force

func _draw() -> void:
	if hooked:
		draw_line(Vector2(0,0), to_local(hook_pos), Color(1,1,1), 3, true)

func hook_process() -> void:
	$Raycast.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("left_click"):
		hook_pos = get_hook_pos()
		if hook_pos != Vector2():
			hooked = true
			rope_len_current = global_position.distance_to(hook_pos)
	
	if Input.is_action_just_released("left_click") and hooked:
		hooked = false

func get_hook_pos() -> Vector2:
	for raycast in $Raycast.get_children():
		if raycast is RayCast2D and raycast.is_colliding():
			return raycast.get_collision_point()
	
	return Vector2()

func swing(delta: float) -> void:
	var radius: Vector2 = global_position - hook_pos
	if velocity.length() < 0.01 or radius.length() < 10: 
		return
	
	var angle: float = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var rad_motion: float = cos(angle) * velocity.length()
	velocity += radius.normalized() * -rad_motion
	
	if global_position.distance_to(hook_pos) > rope_len_current:
		global_position = hook_pos + radius.normalized() * rope_len_current
	
	velocity += (hook_pos - global_position).normalized() * 7000 * delta
	
	# Add horizontal movement while swinging
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x += speed * delta * 0.5  # Reduced speed while swinging
	elif Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x -= speed * delta * 0.5

func move(delta: float) -> void:
	# Use both input actions and direct key presses for better compatibility
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x = speed
	elif Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x = -speed
	else:
		velocity.x = 0
