extends CharacterBody2D

@export var speed: float = 300.0
@export var dash_multiplier: float = 2.5
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

# Health System
var max_health: int = 9
var current_health: int = 9

# Dash State Variables
var is_dashing: bool = false
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var last_movement_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
	print("========================================")
	print("[TERMINAL] Spaceship Initialized.")
	print("[TERMINAL] Max Health: %d | Current Health: %d" % [max_health, current_health])
	print("[TERMINAL] Controls: WASD to Fly | SHIFT to Dash | H to Take 3 Damage")
	print("========================================")

func _input(event: InputEvent) -> void:
	# Dash Mechanic (Triggered by pressing Shift)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SHIFT:
		if not is_dashing and dash_cooldown_left <= 0:
			is_dashing = true
			dash_time_left = dash_duration
			dash_cooldown_left = dash_cooldown
			print("[TERMINAL] >> DASH TRIGGERED! Speed boosted.")

	# Health Damage Test (Triggered by pressing H)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		take_damage(3)

func _physics_process(delta: float) -> void:
	# Handle dash cooldown countdown
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta

	# Gather WASD inputs
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	
	direction = direction.normalized()

	# Remember last direction for dashing when standing still
	if direction != Vector2.ZERO:
		last_movement_dir = direction

	# Calculate velocity based on state
	var current_speed = speed
	if is_dashing:
		current_speed *= dash_multiplier
		velocity = last_movement_dir * current_speed
		dash_time_left -= delta
		if dash_time_left <= 0:
			is_dashing = false
	else:
		velocity = direction * current_speed

	# Move the character
	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health < 0:
		current_health = 0
	
	print("[TERMINAL] >> HEALTH UPDATE: Took %d damage. Current Health: %d/%d" % [amount, current_health, max_health])

	if current_health <= 0:
		print("[TERMINAL] >> GAME OVER: Health reached 0! Restarting scene...")
		call_deferred("_restart_game")

func _restart_game() -> void:
	get_tree().reload_current_scene()
