extends CharacterBody2D

@export_group("Movement")
@export var normal_speed: float = 350.0
@export var acceleration: float = 12.0
@export var friction: float = 8.0

@export_group("Dash")
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.8

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

@export_group("Health System")
@export var max_health: int = 100
var current_health: int = 100

# H-key delay / debounce variables
var h_delay: float = 0.4
var h_timer: float = 0.0

func _ready() -> void:
	current_health = max_health
	print("Spaceship initialized. Press 'H' to test taking damage.")

func _physics_process(delta: float) -> void:
	# Update timers
	if dash_timer > 0:
		dash_timer -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if h_timer > 0:
		h_timer -= delta

	# --- 1. TEST HEALTH SYSTEM WITH 'H' KEY ---
	# Uses a timer delay (debounce) so holding or tapping 'H' doesn't spam inputs instantly
	if Input.is_key_pressed(KEY_H) and h_timer <= 0:
		h_timer = h_delay
		take_damage(15)

	# --- 2. GET WASD INPUT ---
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	# --- 3. HANDLE DASH MECHANIC (SHIFT) ---
	var is_dashing = false
	if Input.is_key_pressed(KEY_SHIFT) and dash_cooldown_timer <= 0 and dash_timer <= 0:
		if input_dir != Vector2.ZERO:
			dash_timer = dash_duration
			dash_cooldown_timer = dash_cooldown
			dash_direction = input_dir

	# --- 4. APPLY MOVEMENT & PHYSICS ---
	if dash_timer > 0:
		# During dash, override velocity completely
		velocity = dash_direction * dash_speed
	else:
		if input_dir != Vector2.ZERO:
			# Smooth acceleration towards target velocity
			velocity = velocity.move_toward(input_dir * normal_speed, acceleration * normal_speed * delta)
		else:
			# Smooth deceleration (friction) when no keys are pressed
			velocity = velocity.move_toward(Vector2.ZERO, friction * normal_speed * delta)

	move_and_slide()

	# Optional: Face the ship toward movement direction or mouse
	if velocity.length() > 10:
		rotation = lerp_angle(rotation, velocity.angle() + PI/2, 15 * delta)

# --- HEALTH FUNCTIONS ---
func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	print("Ouch! Took ", amount, " damage. Health: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	print("Healed for ", amount, ". Health: ", current_health, "/", max_health)

func die() -> void:
	print("Spaceship Destroyed! Game Over.")
	# Add your respawn, particle explosion, or scene reload logic here
