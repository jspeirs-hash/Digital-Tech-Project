extends Area2D
var health = 1


func _on_body_entered(body: Node2D) -> void:
	var enemy = get_tree().get_first_node_in_group("enemy")
	if body == enemy:
		pass
