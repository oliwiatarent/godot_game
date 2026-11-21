extends CanvasLayer

@export_group('Riddle Parameters')
@export var rows: int = 4
@export var columns: int = 4
@export var active_grid: Array[bool] = []
@export var final_grid: Array[bool] = []

@onready var grid = $GridContainer
var buttons_list
var riddle_solved = false

var green = Color.from_rgba8(44, 199, 92, 255)
var red = Color.from_rgba8(189, 9, 10, 255)

func _ready():
	grid.columns = columns
	
	if active_grid.size() != rows * columns:
		active_grid.resize(rows * columns)
	if final_grid.size() != rows * columns:
		final_grid.resize(rows * columns)
	
	generate_grid()
	
	
func generate_grid():
	for row in range(rows):
		for col in range(columns):
			var button = Button.new()
			button.custom_minimum_size = Vector2(200, 200)

			var style_normal = StyleBoxFlat.new()
			style_normal.corner_radius_top_left = 100
			style_normal.corner_radius_top_right = 100
			style_normal.corner_radius_bottom_left = 100
			style_normal.corner_radius_bottom_right = 100
			
			if active_grid[row * columns + col] == true:
				style_normal.bg_color = green
			else:
				style_normal.bg_color = red
			
			button.add_theme_stylebox_override("normal", style_normal)
			button.add_theme_stylebox_override("hover", style_normal)
			button.add_theme_stylebox_override("pressed", style_normal)
			button.pressed.connect(_on_button_clicked.bind(row, col))

			grid.add_child(button)
			
	buttons_list = grid.get_children()


func change_button_state(row, col):
	if row < 0 or row >= rows or col < 0 or col >= columns:
		return
		
	var index = row * columns + col
	active_grid[index] = not active_grid[index]
	
	var button = buttons_list[index]
	var style = button.get_theme_stylebox("normal") as StyleBoxFlat
	
	if style:
		if active_grid[index] == true:
			style.bg_color = green
		else:
			style.bg_color = red
			
			
func check_grid():
	if active_grid == final_grid:
		print('Rozwiazano zagadke')
	return active_grid == final_grid


func _on_button_clicked(row, col):
	if not riddle_solved:
		change_button_state(row, col)
		change_button_state(row + 1, col)
		change_button_state(row - 1, col)
		change_button_state(row, col + 1)
		change_button_state(row, col - 1)
		
		riddle_solved = check_grid()
	
