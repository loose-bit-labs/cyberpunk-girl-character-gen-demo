extends Node

#################################################################################################

const CONFIGURATION_RESOURCE = "user://cyber-city-run.cfg"
const MAIN_AUDIO_BUS = "Master"
const GLOBAL = "global"
const MUTE = "mute"

var configuration : ConfigFile = null

#################################################################################################

func _init() -> void:
	load_config() 

func load_config() -> void:
	configuration = ConfigFile.new()
	var err = configuration.load(CONFIGURATION_RESOURCE)
	if err:
		return
	set_mute(configuration.get_value(GLOBAL, MUTE, false))
	
func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()

func quit() -> void:
	if configuration:
		var err = configuration.save(CONFIGURATION_RESOURCE)
		print("saved configuration to ", CONFIGURATION_RESOURCE, ", err is ", err )
	get_tree().quit()

#################################################################################################

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func grab_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#################################################################################################

func toggle_mute() -> bool:
	var bus_idx = _sound_bus()
	var current = not get_mute(bus_idx)
	set_mute(current, bus_idx)
	AudioServer.set_bus_mute(bus_idx, current)
	configuration.set_value(GLOBAL, MUTE, current)
	return current

func _sound_bus(bus_idx:int = -99, which = MAIN_AUDIO_BUS):
	return bus_idx if bus_idx >= 0 else AudioServer.get_bus_index(which)

func get_mute(bus_idx:int = -99, which = MAIN_AUDIO_BUS) -> bool:
	return AudioServer.is_bus_mute(_sound_bus(bus_idx, which)) 

func set_mute(value, bus_idx:int = -99, which = MAIN_AUDIO_BUS) -> bool:
	bus_idx = _sound_bus(bus_idx, which)
	AudioServer.set_bus_mute(bus_idx, value)
	configuration.set_value(GLOBAL, MUTE, value)
	return value

func is_muted():
	return get_mute()


#################################################################################################

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound

#################################################################################################

# c/p from our scaletris project
func camera_mouse(context:Node3D, camera:Camera3D, exclude = [], rayLength:float=1000) -> Node3D:
	var space_state = context.get_world_3d().direct_space_state
	var mousepos = context.get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * rayLength
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.exclude = exclude

	var result = space_state.intersect_ray(query)
	if !result or not "collider" in result: 
		return null
	return result.collider

func toggle_fullscreen() -> void:
	if DisplayServer.WINDOW_MODE_FULLSCREEN == DisplayServer.window_get_mode():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
