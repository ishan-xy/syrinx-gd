extends Node2D

@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var currentPlayer = PlayerScene.instantiate()
	currentPlayer.name = "Player1"
	add_child(currentPlayer)
	for spawn in get_tree().get_nodes_in_group("PlayerSpwnPoint"):
		if spawn.name == "1":
			currentPlayer.global_position = spawn.global_position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
