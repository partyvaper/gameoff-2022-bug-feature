extends Node3D

# func _ready() -> void:
#	pass

#func _process(delta: float) -> void:
#	pass

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Main.tscn")
