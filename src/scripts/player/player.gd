extends CharacterBody2D

@export var speed: float = 0
@export var gravity: float = 0

var motion = Vector2()
var hook_pos = Vector2()
var hooked = false

var rope_len = 500
var rope_len_current

func _ready() -> void:
	rope_len_current = rope_len 
	
func _physics_process(delta: float) -> void:
	gravity_process()
	
func gravity_process() -> void:
	motion.y += gravity
	
func hook_process() -> void:
	$Raycast.look_at(get_global_mouse_position())

func move(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		motion.x += speed
	elif Input.is_action_pressed("ui_left"):
		motion.x -= speed
	else:
		motion.x = 0
