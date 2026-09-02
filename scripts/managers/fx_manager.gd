extends Node

## Autoload singleton: FxManager
## Add as Autoload named "Fx" in Project Settings.
## Usage: Fx.burst(global_pos)  or  Fx.burst(global_pos, Color.SANDY_BROWN)
##
## Generic one-shot particle burst for interaction feedback (till, water,
## harvest, plant, animal harvest, etc). No custom particle art yet — uses
## CPUParticles2D's default flat-square look, tinted per-call via `color`.
## Swap in a real texture on particle_burst.tscn later without touching
## any of the call sites below.

const ParticleBurstScene: PackedScene = preload("res://scenes/vfx/particle_burst.tscn")


func burst(world_position: Vector2, color: Color = Color.WHITE) -> void:
	var tree: SceneTree = Engine.get_main_loop()
	if tree == null or tree.current_scene == null:
		return
	var fx: CPUParticles2D = ParticleBurstScene.instantiate()
	tree.current_scene.add_child(fx)
	fx.global_position = world_position
	fx.color = color
	fx.play()
