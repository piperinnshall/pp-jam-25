extends CharacterBody2D

@export var speed: float
@export var gravity: float

var motion: Vector2 = Vector2()
var hook_pos: Vector2 = Vector2()
var hooked: bool

var rope_len: float = 500
var rope_len_current: float

func _ready() -> void:
	rope_len_current = rope_len 
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("key_a"):
		position.x -= speed
	elif Input.is_action_pressed("key_d"):
		position.x += speed
		
	gravity_process()
	hook_process()
	if hooked:
		gravity_process()
	
func gravity_process() -> void:
	motion.y += gravity
	
func hook_process() -> void:
	$Raycast.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("left_click"):
		hook_pos = get_hook_pos()
		if hook_pos:
			hooked = true
			rope_len_current = global_position.distance_to(hook_pos)
			
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
	var rad_velocity: float = cos(angle) * motion.length()
	motion += radius.normalized()

func move(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		motion.x += speed
	elif Input.is_action_pressed("ui_left"):
		motion.x -= speed
	else:
		motion.x = 0
