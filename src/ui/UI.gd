extends CanvasLayer

class_name UI

var debug_texts: Dictionary = { }

@onready var debug_text: Control = $debug_text
# @onready var player: Entity3D = $"/root/Game/Player3D"p

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# scale *= Game.ui_scale

func _process(delta: float) -> void:
	pass

func set_debug_text (key: String, val: String = '') -> void:
	debug_texts[key] = val
	var final_string = ''
	for title in debug_texts:
		final_string += str(title, ': ', debug_texts[title], '\n')
	debug_text.set_text(final_string)
