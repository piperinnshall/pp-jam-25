extends Area2D

func _ready():
	# Connect both signals to handle different collision types
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)
	
	# Make sure monitoring is enabled
	monitoring = true

func _on_body_entered(body: Node) -> void:
	print("Body entered: ", body.name, " Groups: ", body.get_groups())
	if body.is_in_group("Branch"):
		body.get_parent().queue_free()

func _on_area_entered(area: Node) -> void:
	print("Area entered: ", area.name, " Groups: ", area.get_groups())
	if area.is_in_group("Branch"):
		area.get_parent().queue_free()
