-- sets random value to each key without "candy look" effect
math.randomseed(os.time())
for y = 0,7 do
	for x = 0,15 do
		keyboard(KEY, x,y,
			ite(math.random(0,1)>0,math.random(0,255),0),
			ite(math.random(0,1)>0,math.random(0,255),0),
			ite(math.random(0,1)>0,math.random(0,255),0)
		)
	end
end
keyboard(SET) -- second parameter not needed, because it's Preset.CUSTOM by default
