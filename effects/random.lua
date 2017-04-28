math.randomseed(os.time())
for y = 0,7 do
	for x = 0,15 do
		keyboard_key(x,y,
			math.random(0,255),
			math.random(0,255),
			math.random(0,255)
		)
	end
end
keyboard_update()
