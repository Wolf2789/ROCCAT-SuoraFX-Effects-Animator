-- sets each key to random value giving candy look
math.randomseed(os.time())
for y = 0,7 do
	for x = 0,15 do
		keyboard(KEY, x,y,
			math.random(0,255),
			math.random(0,255),
			math.random(0,255)
		)
	end
end
keyboard(SET) -- second parameter not needed, because it's Preset.CUSTOM by default
