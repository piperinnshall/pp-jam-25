extends StaticBody2D

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Spike"):
		get_parent().queue_free()  # Delete the parent Branch node
