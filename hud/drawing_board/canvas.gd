extends ColorRect
class_name Canvas

func _ready():
	clip_contents = true

func create_line(line_color: Color, line_width: float, brush_mask: Texture2D, line_name: String) -> Line2D:
	var new_line = Line2D.new()
	new_line.name = line_name
	new_line.default_color = line_color
	new_line.width = line_width
	new_line.joint_mode = Line2D.LINE_JOINT_ROUND 
	new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.antialiased = true
	new_line.texture = brush_mask
	new_line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	add_child(new_line)
	return new_line

func clear():
	for child in get_children():
		if child is Line2D:
			child.queue_free()

func undo():
	var lines: Array = []
	
	for child in get_children():
		if child is Line2D:
			lines.append(child)
			
	if lines.size() > 0:
		lines.back().queue_free()
