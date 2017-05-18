-- each run switches preset speed
keyboard(SPEED,
	(keyboard(SPEED) + 1) % 10
)
keyboard(SET, Preset.RAIN)
