extends Control

func _ready():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var save_game = File.new()
		if not save_game.file_exists("user://savegame.save"):
			$load.set_disabled(1)
		var _load_pressed = $load.connect("pressed", self, "_on_load_pressed")
		var _exit_pressed = $Exit.connect("pressed", self, "_on_exit_pressed")
# When a Host button is pressed
func _on_ded_pressed():
# warning-ignore:return_value_discarded
	var cs = "res://scenes/new-lev1.tscn"
	get_tree().change_scene(cs)

func _on_exit_pressed():
	if OS.has_feature('JavaScript'):
		get_tree().change_scene("res://scenes/blank.tscn")
	else:
		get_tree().quit()

		
func _on_load_pressed():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])

	save_game.close()

