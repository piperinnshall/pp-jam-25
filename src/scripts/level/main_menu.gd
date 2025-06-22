extends Control



func _on_button_button_down() -> void:
	print("Button pressed!")
	# Use call_deferred to ensure the scene change happens safely
	call_deferred("change_scene")

func change_scene():
	if get_tree():
		get_tree().change_scene_to_file("res://src/scenes/level/World.tscn")
