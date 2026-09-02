extends CPUParticles2D

## One-shot particle burst. Fx.burst() instantiates this, positions it,
## optionally tints it, and calls play() — this script just frees itself
## once the burst has fully finished (lifetime + one_shot fade-out).

func play() -> void:
	emitting = true
	await get_tree().create_timer(lifetime + 0.1).timeout
	queue_free()
