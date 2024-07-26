extends CanvasLayer
signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("ay te bañaste")
	await $MessageTimer.timeout
	
	$Message.text = "Dodge da creeps!"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)
	
func update_powerups(count):
	for child in get_tree().get_nodes_in_group("HUD_powerups"):
		remove_child(child)
	for i in range(count):
		var new_power = $PowerUpLabelBase.duplicate()
		new_power.position.x = 32 + i*32
		new_power.visible = true
		new_power.add_to_group("HUD_powerups")
		add_child(new_power)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
