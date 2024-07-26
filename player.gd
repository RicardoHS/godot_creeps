extends Area2D
signal hit
signal power_up_hit(body)
signal enemy_killed(body)
signal power_up_used

@export var speed = 400
var screen_size
var powerup_active
var n_powerups

func start(pos):
	position = pos
	powerup_active = false	
	n_powerups = 0
	show()
	$CollisionShape2D.disabled = false
	$CollisionElectricShield.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("activate_powerup") and not powerup_active and n_powerups > 0:
		n_powerups -= 1
		powerup_active = true
		power_up_used.emit()
		$ElectricShield.visible = true
		$PowerUpTimer.start()
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		
	if $PowerUpTimer.is_stopped():
		powerup_active = false
		$CollisionElectricShield.disabled = true
		$ElectricShield.visible = false



func _on_body_entered(body):
	if body.collision_layer == 1:
		# Its an enemy
		if powerup_active:
			enemy_killed.emit(body)
		else:
			hide()
			hit.emit()
			$CollisionShape2D.set_deferred("disabled", true)
	
	if body.collision_layer == 3:
		# its a powerup
		power_up_hit.emit(body)
		n_powerups += 1
