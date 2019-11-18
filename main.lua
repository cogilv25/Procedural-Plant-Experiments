-- Written by Calum Lindsay.

-- A while ago I stumbled across this paper
-- (http://algorithmicbotany.org/papers/lsfp.pdf)
-- and was intrigued so I made this small program
-- capable of generating some of the fractals
-- described in the paper copying a few of
-- the patterns in the paper and attempting a
-- couple of my own. It's not very easy to read
-- however as it was never really intended to be
-- but I think I might come back to it and tidy
-- up because it's really quite a fascinating
-- subject.

-- Controls:
-- Up and Down - zoom in and out
-- Left and Right - step generator back and forward
-- Comma and Dot - previous and next generator
function newGenerator(name, initialValue, angle, rules)
	local gen = {}
	gen.initial = initialValue
	gen.angle = angle
	gen.rules = rules
	gen.name = name
	return gen
end

--PP = Przemyslaw Prusinkiewicz
--JH = James Hanan
--CL = Calum Lindsay
generators = {}
generators[1] = newGenerator("Plant by PP & JH", "F", 25.7, {"F","F[+F]F[-F]F"})
generators[2] = newGenerator("Plant by PP & JH", "X", 22.5, {"X","F-[[X]+X]+F[+FX]-X","F","FF"})
generators[3] = newGenerator("Plant by PP & JH", "Y", 25.7, {"Y","YFX[+Y][-Y]","X","X[-FFF][+FFF]FX"})
generators[4] = newGenerator("Plant by PP & JH", "F", 22.5, {"F","FF+[+F-F-F]-[-F+F+F]"})
generators[5] = newGenerator("Plant by PP & JH", "X", 20, {"X","F[+X]F[-X]+X","F","FF"})
generators[6] = newGenerator("Circle pattern 1 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF"})
generators[7] = newGenerator("Circle pattern 2 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF"})
generators[8] = newGenerator("Circle pattern 3 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf"})
generators[9] = newGenerator("Circle pattern 4 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf"})
generators[10] = newGenerator("Circle pattern 5 by CL","fffffffffffffffffffffffffffffffffffffffffffff---F", 22.5,{"F","+++fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf"})
generators[11] = newGenerator("Square pattern by CL","fffffffffffffffffff---F", 90,{"F","+++fFfFf+fFfFf+fFfFf+fFfFf"})
generators[12] = newGenerator("Triangle pattern 1 by CL","fffffffffffffffffff---F", 120,{"F","fFfFf+fFfFf+fFfFf+fFfFf"})
generators[13] = newGenerator("Triangle pattern 2 by CL","fffffffffffffffffff---F", 120,{"F","fFfFf+fFfFf+fFfFf"})
generators[14] = newGenerator("Triangle pattern 3 by CL","fffffffffffffffffff---F", 120,{"F","++fFfFf+fFfFf"})
generators[15] = newGenerator("Pentagon pattern 1 by CL","fffffffffffffffffff---F", 72,{"F","FFFFF+FFFFF+FFFFF+FFFFF+FFFFF"})
generators[16] = newGenerator("Hexagon pattern 1 by CL","fffffffffffffffffff---F", 60,{"F","FFFFF+FFFFF+FFFFF+FFFFF+FFFFF+FFFFF"})
generators[17] = newGenerator("Heptagon pattern 1 by CL","fffffffffffffffffff---F", 51.4287,{"F","FFFFF+FFFFF+FFFFF+FFFFF+FFFFF+FFFFF+FFFFF"})
generators[18] = newGenerator("Heptagon pattern 2 by CL","fffffffffffffffffff---F", 51.4287,{"F","FFfFF+FFfFF+FFfFF+FFfFF+FFfFF+FFfFF+FFfFF"})
generators[19] = newGenerator("Heptagon pattern 3 by CL","fffffffffffffffffff---F", 51.4287,{"F","FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF"})




--Not sure about these nested functions
function newStack()
	local stack = {data={}}
	function stack:push(val)
		table.insert(self.data,val)
	end
	function stack:pop()
		return table.remove(self.data)
	end
	return stack
end

screenWidth,screenHeight = 800,600
startpos = {screenWidth/2,screenHeight}
pos = {400,600}
dir = {0,0}
drawMode = "polygon"
drawColor = {255,255,255,255}
drawScale = 5
genChoice = 1

function choiceChanged()
	angle = math.rad(generators[genChoice].angle)
	initiator = generators[genChoice].initial
	ruleset = generators[genChoice].rules
	pos = {startpos[1],startpos[2]}
	n = 0
	scale = 1
	stack = newStack()
	needToUpdate = true
	dir = {0,-5}
	state = initiator
end

function stepForward()
	n = n + 1
	oldState = state
	state = ""

	--step through all chars in oldState
	for instruction in oldState:gmatch"." do
		local lgen = #ruleset / 2
		for i=1,lgen do
			if(instruction == ruleset[i*2-1])then
				state = state .. ruleset[i*2]
			else
				if(i == lgen)then
					state = state .. instruction
				end
			end
		end
	end

	needToUpdate = true
end

function stepBack()
	local t = n-1
	pos = {startpos[1],startpos[2]}
	stack = newStack()
	dir = {0,-5}
	state = initiator
	for i=1,t do
		stepForward()
	end
	n = t
	needToUpdate = true
end


function love.load()
	locus = {}
	stack = newStack()
	needToUpdate = true
	scale = 1
	framebuffer = love.graphics.newCanvas(screenWidth, screenHeight)
	choiceChanged()
end

--[[

function threadedDrawFunction()
	--Do we need to block other threads doing draw operations?
	--What if another thread called setCanvas?
	local frame
	love.graphics.setCanvas(frame)
	love.graphics.scale(scale,scale)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")
	love.graphics.setColor(drawColor)

	if(drawMode == "dot") then
		for point in locus do
			love.graphics.circle("fill",point[1],point[2],drawScale)
		end
	elseif(drawMode == "line")then
		for line in locus do
			love.graphics.line(line[1],line[2],line[3],line[4])
		end
	end

	--Return to normal framebuffer
	love.graphics.setCanvas()
	return frame
end

]]


function love.draw()
	--Only draw when neccessary (when changes are made and draw in seperate thread to a texture)
	-- love.graphics.setBlendMode("alpha", "premultiplied") <- before drawing prerendered frame
	-- love.graphics.setBlendMode("alpha") <- afterwards reset blend mode
	love.graphics.clear()
	love.graphics.setColor(drawColor)
	if(drawMode == "dot") then
		for k,p in pairs(locus) do
			love.graphics.circle("fill",p[1],p[2],drawScale)
		end
	elseif(drawMode == "line")then
		for k,p in pairs(locus) do
			love.graphics.line(p[1],p[2],p[3],p[4])
		end
	elseif(drawMode == "triangle" and #locus>=3)then
		for i=1,#locus/3 do
			local t = {locus[i][1],locus[i][2],locus[i+1][1],locus[i+1][2],
				locus[i+2][1],locus[i+2][2]}
			love.graphics.polygon("line",t)
		end
	elseif(drawMode == "polygon" and #locus>=3)then
		local t = {}
		for k,p in pairs(locus) do
			table.insert(t,p[1])
			table.insert(t,p[2])
		end
		love.graphics.polygon("line",t)
	end
	love.graphics.print("n="..n,0,0)
	love.graphics.printf(generators[genChoice].name,0,0,800,"center")
	love.graphics.printf(genChoice.."/"..#generators,0,0,800,"right")
end

function love.update(d)
	if(needToUpdate)then
		locus = {}
		pos = {startpos[1],startpos[2]}
		pos[1],pos[2] = pos[1]/scale, pos[2]/scale

        --TODO: replace strings as well as individual characters
		for instruction in state:gmatch"." do

			if(instruction == 'f')then
				pos[1],pos[2] = pos[1]+dir[1],pos[2]+dir[2]
			elseif(instruction == 'F')then
				local t = {pos[1],pos[2]}
				pos[1],pos[2] = pos[1]+dir[1],pos[2]+dir[2]
				locus[#locus+1] = {t[1],t[2],pos[1],pos[2]}
			elseif(instruction == '-')then
				local lx = dir[1]
				local ly = dir[2]
				dir[1] = lx * math.cos(-angle) - ly * math.sin(-angle)
				dir[2] = ly * math.cos(-angle) + lx * math.sin(-angle)
			elseif(instruction == '+')then
				local lx = dir[1]
				local ly = dir[2]
				dir[1] = lx * math.cos(angle) - ly * math.sin(angle)
				dir[2] = ly * math.cos(angle) + lx * math.sin(angle)
			elseif(instruction == ']')then
				dir[2] = stack:pop()
				dir[1] = stack:pop()
				pos[2] = stack:pop()
				pos[1] = stack:pop()
			elseif(instruction == '[')then
				stack:push(pos[1])
				stack:push(pos[2])
				stack:push(dir[1])
				stack:push(dir[2])
			end
		end
		needToUpdate = false
		dir = {0,-5}
	end
end

function love.keypressed(key)
	if(key == "escape")then
		love.event.quit()
	end
	if(key == "left" or key == "a")then
		--step back
		if(n>0)then
			stepBack()
		end
	end
	if(key == "right" or key == "d")then
		--step forward
		stepForward()
	end
	if(key == "down" or key == "s")then
		if(scale > 0.2)then
			scale = scale * 0.75
			needToUpdate = true
		end
	end
	if(key == "up" or key == "w")then
		if(scale < 8)then
			scale = scale*1.33333
			needToUpdate = true
		end
	end
	if(key == ".")then
		if(genChoice< #generators)then
			genChoice = genChoice + 1
			choiceChanged()
		end
	end
	if(key == ",")then
		if(genChoice>1)then
			genChoice = genChoice - 1
			choiceChanged()
		end
	end
end