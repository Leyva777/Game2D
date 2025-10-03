extends Node

@export var mob_scene: PackedScene
@export var egg_box_scene: PackedScene 
var score
var egg_box_spawn_timer = 0
var EGG_BOX_SPAWN_TIME = 10  # Aparece cada 10 segundos

func _ready():
	# Conectar la señal de la caja de huevos si existe
	if egg_box_scene:
		# conectada en cada instancia
		pass

func _process(delta):
	if egg_box_scene and $MobTimer.is_stopped() == false:
		egg_box_spawn_timer += delta
		if egg_box_spawn_timer >= EGG_BOX_SPAWN_TIME:
			spawn_egg_box()
			egg_box_spawn_timer = 0

func spawn_egg_box():
	var egg_box = egg_box_scene.instantiate()
	
	# spawn aleatorio
	var viewport_size = get_viewport().get_visible_rect().size
	egg_box.position = Vector2(
		randf_range(50, viewport_size.x - 50),
		randf_range(50, viewport_size.y - 50)
	)
	
	# Conectar la señal de recogida para efectos
	egg_box.picked_up.connect(_on_egg_box_picked_up)
	
	add_child(egg_box)

func _on_egg_box_picked_up():
	print('Proteccion: True')
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	egg_box_spawn_timer = 0  # Resetear el timer

func new_game():
	get_tree().call_group(&"mobs", &"queue_free") #limpiar mobs
	get_tree().call_group(&"egg_boxes", &"queue_free")  #limpiar cajas
	score = 0
	egg_box_spawn_timer = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Muevete!")
	$Music.play()
func _on_MobTimer_timeout():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()
	mob.position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	add_child(mob)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
