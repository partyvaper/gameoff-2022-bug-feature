extends Control

# Script used to draw debug stuff

var points: Array = []

func clear_points() -> void:
	points = []
	queue_redraw()

func add_point(pos: Vector2, color: Color) -> void:
	points.append({
		pos = pos,
		color = color,
	})
	queue_redraw()

func _physics_process(delta: float) -> void:
	queue_redraw()

func _process(delta: float) -> void:
	queue_redraw()

func _draw():
	var len: int = points.size()
	for i in range(len):
		var p = points[i]
		draw_circle(p.pos, 4, p.color)
		if (i+1 < len):
			var p2 = points[i+1]
			if (p.color == p2.color):
				draw_dashed_line(p.pos, p2.pos, p.color, 2, 4)
