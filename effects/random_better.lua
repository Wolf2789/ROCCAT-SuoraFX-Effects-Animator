math.randomseed(os.time())
for y = 0,7 do
	for x = 0,15 do
		keyboard_key(x,y,
			ite(math.random(0,1)>0,math.random(0,255),0),
			ite(math.random(0,1)>0,math.random(0,255),0),
			ite(math.random(0,1)>0,math.random(0,255),0)
		)
	end
end
keyboard_update()
