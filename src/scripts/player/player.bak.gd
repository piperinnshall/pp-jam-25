extends CharacterBody2D

var speed: float = 450
var gravity: float = 100

var motion: Vector2 = Vector2()
var hook_pos: Vector2 = Vector2()
var hooked: bool = false

var rope_len: float = 500
var rope_len_current: float

func _ready() -> void:
	rope_len_current = rope_len 

func _physics_process(delta: float) -> void:
	gravity_process()
	hook_process()
	queue_redraw()
	if hooked:
		gravity_process()
		swing(delta)
		motion *= 0.975
		motion = move_and_slide(motion)
	move(delta)
	motion = move_and_slide(motion)

func gravity_process() -> void:
	motion.y += gravity

func _draw() -> void:
	var pos = global_position
	if hooked:
		draw_line(Vector2(0,0), to_local(hook_pos), Color(1,1,1), 3, true)
	else:
		return
	var colliding = $Raycast.is_colliding
	var colliding_point = $Raycast.get_collision_point()
	if colliding and pos.distance_squared_to(colliding_point) < rope_length:
		draw_line(Vector2(0,0), to_local(hook_pos), Color(0,0,0), 3, true)

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
	if motion.length() < 0.01 or radius.length() < 10: 
		return
	var angle: float = acos(radius.dot(motion) / (radius.length() * motion.length()))
	var rad_motion: float = cos(angle) * motion.length()
	motion += radius.normalized() * -rad_motion
	
	if global_position.distance_to(hook_pos) > rope_len_current:
		global_position = hook_pos + radius.normalized() * rope_len_current
	
	motion += (hook_pos - global_position).normalized() * 15000 *delta

func move(delta: float) -> void:
	if Input.is_action_pressed("key_d"):
		motion.x = speed
	elif Input.is_action_pressed("key_a"):
		motion.x = -speed
	else:
		motion.x = 0
