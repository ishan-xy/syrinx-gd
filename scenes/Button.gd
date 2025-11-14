extends Button

# Declare variables for default and hover font sizes
var default_font_size = 32
var hover_font_size = 34
var pressed_font_size = 36

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect signals to their respective functions
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_pressed)
	
	# Set the default font size
	set_font_size(default_font_size)

# Function to handle mouse hover
func _on_mouse_entered():
	set_font_size(hover_font_size)

# Function to handle mouse exit
func _on_mouse_exited():
	set_font_size(default_font_size)

# Function to handle button press
func _on_button_pressed():
	set_font_size(pressed_font_size)

# Helper function to set font size
func set_font_size(size):
	var font = self.get("custom_fonts/font")
	if font:
		font.size = size
		self.set("custom_fonts/font", font)
