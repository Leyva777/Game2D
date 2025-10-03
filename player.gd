extends Area2D

signal hit

@export var speed = 400
@export var egg_box_texture: Texture2D  # Texture para el cartón de huevos
var screen_size
var has_extra_life = false  # Controla si tiene la vida extra
var original_texture  # Guarda la textura original del huevo

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	original_texture = $AnimatedSprite2D.sprite_frames

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		rotation = PI if velocity.y > 0 else 0

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false
	# Resetear a estado normal al comenzar nuevo juego
	reset_to_normal()

func get_extra_life():
	if not has_extra_life:
		has_extra_life = true
		# Cambio visual
		modulate = Color(0.7, 0.9, 1.0)  # Color azul claro
		print("vida extra - Estado: ", has_extra_life)
	else:
		print("")

func lose_extra_life():
	if has_extra_life:
		has_extra_life = false
		reset_to_normal()
		return true  # perdio vida extra
	return false  # no tenía vida extra

func reset_to_normal():
	has_extra_life = false
	# Restaurar apariencia normal
	if $AnimatedSprite2D.sprite_frames.has_animation("right"):
		$AnimatedSprite2D.animation = "right"
	modulate = Color(1, 1, 1)  # Color normal

func _on_body_entered(body):
	# Si tiene vida extra, la pierde pero no termina el juego
	if has_extra_life and body.is_in_group("mobs"):
		lose_extra_life()
		#$HitSound.play() 
	else:
		# No tiene protección, game over normal
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred(&"disabled", true)
