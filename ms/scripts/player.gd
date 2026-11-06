extends CharacterBody2D
class_name Player

# =====================
# SIGNALS
# =====================
signal health_changed(value: int)

# =====================
# CONFIG
# =====================
@export var speed := 260.0
@export var jump_velocity := -420.0
@export var max_health := 3
@export var portal_scene: PackedScene

# =====================
# NODES
# =====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Area2D
@onready var vignette_rect: ColorRect = $postpp/CanvasLayer2/ColorRect
@onready var vignette_mat: ShaderMaterial = vignette_rect.material

# =====================
# STATE
# =====================
var health := max_health
var dead := false
var facing_right := true
var hit_lock := false

# =====================
# READY
# =====================
func _ready():
	add_to_group("player")
	health = max_health
	health_changed.emit(health)

	hitbox.body_entered.connect(_on_hitbox_body_entered)

	if vignette_mat:
		vignette_mat.set_shader_parameter("strength", 0.25)







# =====================
# PHYSICS
# =====================
func _physics_process(delta):
	if dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = dir * speed
		_update_facing(dir)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	_update_animation()
	move_and_slide()

# =====================
# INPUT
# =====================
func _unhandled_input(event):
	if dead:
		return

	if event.is_action_pressed("horn_next"):
		GameManager.cycle_horn()

	if event.is_action_pressed("play_horn"):
		GameManager.play_horn(global_position)

	if event.is_action_pressed("interact"):
		_handle_portal_interaction()

# =====================
# PORTAL INTERACTION
# =====================
func _handle_portal_interaction():
	var portals := get_tree().get_nodes_in_group("portals")
	var interacted := false

	# 1️⃣ Check if near existing portal
	for portal in portals:
		if portal.is_inside_tree() and global_position.distance_to(portal.global_position) <= portal.interaction_radius:
			portal.interact_player(self)
			interacted = true
			break  # teleport once

	# 2️⃣ Spawn new portal if not near one
	if not interacted:
		if GameManager.portals_used < GameManager.MAX_PORTALS:
			var portal := portal_scene.instantiate()
			get_tree().current_scene.add_child(portal)
			portal.global_position = global_position
			GameManager.portals_used += 1
			GameManager.portals_changed.emit(GameManager.portals_used, GameManager.MAX_PORTALS)
		else:
			GameManager.fail("NO PORTALS LEFT")



func _place_portal():
	if not GameManager.try_place_portal():
		GameManager.fail("NO PORTALS LEFT")
		return

	if portal_scene == null:
		push_error("Portal scene not assigned")
		return

	var portal := portal_scene.instantiate()
	get_tree().current_scene.add_child(portal)
	portal.global_position = global_position

# =====================
# HEALTH
# =====================
func take_damage(amount := 1):
	if hit_lock or dead:
		return

	hit_lock = true
	health -= amount
	health_changed.emit(health)

	_flash_vignette()

	if health <= 0:
		die("YOU DIED")
	else:
		await get_tree().create_timer(0.3).timeout
		hit_lock = false

func die(reason: String):
	if dead:
		return

	dead = true
	velocity = Vector2.ZERO
	GameManager.fail(reason)

func fell_into_void():
	die("YOU FELL")

# =====================
# HITBOX
# =====================
func _on_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage(1)

# =====================
# VISUALS
# =====================
func _update_animation():
	if not is_on_floor():
		sprite.play("jump")
	elif abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")

func _update_facing(dir: float):
	if dir > 0 and not facing_right:
		facing_right = true
		sprite.flip_h = false
	elif dir < 0 and facing_right:
		facing_right = false
		sprite.flip_h = true

func _flash_vignette():
	if vignette_mat == null:
		return

	var tween := create_tween()
	tween.tween_property(
		vignette_mat,
		"shader_parameter/strength",
		0.9,
		0.15
	)
	tween.tween_property(
		vignette_mat,
		"shader_parameter/strength",
		0.25,
		0.4
	)
