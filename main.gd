extends Node2D

@export var mob_scene: PackedScene
@export var powerup_scene: PackedScene
@export var death_animation: PackedScene
var score
var power_ups

# Called when the node enters the scene tree for the first time.
func _ready():
	$Music.stream.loop = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ColorRect.material.set_deferred("shader_parameter/static_noise_intensity", sin($ShaderTimer.time_left**0.3*PI)*0.2)
	$ColorRect.material.set_deferred("shader_parameter/aberration", sin(($ShaderTimer.time_left*PI)**1.5)*0.13)
	$ColorRect.material.set_deferred("shader_parameter/warp_amount", sin(($ShaderTimer.time_left**0.9))*0.4 + 0.8)



func new_game():
	score = 0
	power_ups = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$PowerUpSpawn.start()
	$Music.play()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$PowerUpSpawn.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	power_ups = 0
	$HUD.update_powerups(power_ups)
	for power in get_tree().get_nodes_in_group("PowerUp"):
		remove_child(power)
	
func adquire_powerup(body):
	remove_child(body)
	$PowerUpSound.play()
	power_ups += 1
	$HUD.update_powerups(power_ups)
	
func use_powerup():
	$PowerUpUsedSound.play()
	power_ups -= 1
	$HUD.update_powerups(power_ups)
	

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI/4, PI/4)
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)


func _on_power_up_spawn_timeout():
	var powerup = powerup_scene.instantiate()
	var viewport = get_viewport_rect().size
	var spawn_position = Vector2(randf_range(0.0, viewport.x), randf_range(0.0, viewport.y))
	
	powerup.position = spawn_position
	add_child(powerup)


func _on_player_enemy_killed(body):
	remove_child(body)
	var anim = death_animation.instantiate()
	anim.position = body.position
	add_child(anim)
	$MobDeathSound.play()
	score += 1
	$HUD.update_score(score)
