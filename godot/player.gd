extends CharacterBody3D

const SPEED = 5.5
const JUMP_VELOCITY = 4.4

# Control variables
@export var camera_distance: float = 2.2
@export var camera_speed: float = 0.005
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 1.0
@export var max_zoom: float = 50.0
# References to your camera and pivot nodes
var camera_rotation: Vector2 = Vector2.ZERO

@onready var camera: Camera3D = $Camera
@onready var pivot: Node3D = $Pivot
@onready var animationPlayer : AnimationPlayer =  $"Pivot/toon/AnimationPlayer"
@onready var toon = $"Pivot/toon"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# respawn if we fall thru the floor or offf the edge
	if position.y < -1:
		position.y = 7.7
		position.x = 0
		position.z = 0

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	var jumping = false
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		toon.rotation.y = camera_rotation.y
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	animationPlayer.play(_pick_animation(input_dir, jumping))
	_update_camera(delta)
	move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	
	# Mouse motion to rotate the camera
	if event is InputEventMouseMotion: # and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		camera_rotation.x -= event.relative.y * camera_speed
		camera_rotation.y -= event.relative.x * camera_speed

	# Clamping the camera's x rotation to prevent flipping over
	var camera_range = 77
	camera_rotation.x = clamp(camera_rotation.x, deg_to_rad(-camera_range * 1), deg_to_rad(-camera_range * .02))
	
	# Mouse wheel to zoom in/out
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = max(camera_distance - zoom_speed, min_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = min(camera_distance + zoom_speed, max_zoom)

func _update_camera(_delta) -> void:
	# Calculate camera position based on rotation and distance
	var direction: Vector3 = Vector3(
		sin(camera_rotation.y) * cos(camera_rotation.x),
		sin(camera_rotation.x),
		cos(camera_rotation.y) * cos(camera_rotation.x)
	)
	# Update the camera's position
	camera.global_transform.origin = pivot.global_transform.origin - direction * camera_distance
	
	# Make the camera look at the pivot
	var at = pivot.global_transform.origin + Vector3(0,.77,0)
	camera.look_at(at, Vector3.UP)

func _pick_animation(input_dir, jumping) -> String:
	var animation = "idle"
	var speed = velocity.dot(velocity)
	if speed > .1:
		animation = "walking"
	if speed > 5:
		animation = _pick_run_animation(input_dir)
	if jumping:
		animation= "jump_up"
	else:
		if !is_on_floor():
			animation = "falling"
	return animation
	
func _pick_run_animation(input_dir) -> String:
	var threshold = .0330
	if input_dir.x > threshold:
		return "run_right"
	elif input_dir.x < -threshold:
		return "run_left"
	return "running"
