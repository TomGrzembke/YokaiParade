extends CanvasLayer  # Attach this script directly to the CanvasLayer node

var current_level = 1  # Example level, this can change during gameplay

func _ready():
	# Set the initial UI colors based on the current level
	set_ui_colors(current_level)

func set_ui_colors(level: int):
	var color_to_apply = Color(1, 1, 1)  # Default to white

	match level:
		1:
			color_to_apply = Color(0.5, 0, 0.8)  # Purple
		2:
			color_to_apply = Color(0, 0.8, 0.5)  # Greenish
		3:
			color_to_apply = Color(1, 0, 0)      # Red

	# Apply the color to the CanvasLayer's children (Sprite2D, Label, etc.)
	apply_modulate(self, color_to_apply)

# Recursive function to apply modulate to the node and its children
func apply_modulate(node: Node, color: Color):
	# Only apply modulate to nodes that support it (Sprite2D, Control, etc.)
	if node is CanvasItem:  # CanvasItem is the base class for nodes like Sprite2D and Control
		node.modulate = color

	for child in node.get_children():
		apply_modulate(child, color)
