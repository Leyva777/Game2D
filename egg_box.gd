extends Area2D

signal picked_up

func _ready():
	# Añadir una animación flotante
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 5, 0.8)
	tween.tween_property(self, "position:y", position.y, 0.8)
	tween.set_loops()
	
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	print("EggBox: Colisión con área: ", area.name)
	print("EggBox: Grupos del área: ", area.get_groups())
	
	# CORRECCIÓN: El área SÍ es el jugador, no necesitamos buscar el padre
	if area.is_in_group("player"):
		print("EggBox: ¡Jugador detectado! Otorgando vida extra...")
		if area.has_method("get_extra_life"):
			area.get_extra_life()  # Llamar directamente al área (que es el jugador)
		else:
			print("ERROR: El área no tiene método get_extra_life")
		
		picked_up.emit()
		
		# Efecto de recolección
		var tween = create_tween()
		tween.tween_property(self, "scale", scale * 1.5, 0.2)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
		tween.tween_callback(queue_free)
	else:
		print("EggBox: El área no es el jugador")
