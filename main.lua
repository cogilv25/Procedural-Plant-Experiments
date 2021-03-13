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

-- TODO:
-- 1)Tidy & Comment 
-- 2)Make a generator class
-- 3)Why not push actor:getCopy() onto stack
-- 4)Optimize to allow more steps without lag
-- 5)Define what instructions (f,F,+,-) do in a table

function LSystemGenerator(name, initialValue, angle, rules)
	local gen = {}
	gen.initial = initialValue
	gen.angle = angle
	gen.rules = rules
	gen.name = name
	return gen
end

--require "LSystemGenerator"
Object = require "lib/thirdparty/classic/classic"
require "lib/containers/stack"
require "lib/game/vector"
require "lib/game/entity"
n = 0

--PP = Przemyslaw Prusinkiewicz
--JH = James Hanan
--CL = Calum Lindsay
generators = {}
generators[1] = LSystemGenerator("Plant by PP & JH", "F", 25.7, {"F","F[+F]F[-F]F"})
generators[2] = LSystemGenerator("Plant by PP & JH", "X", 22.5, {"X","F-[[X]+X]+F[+FX]-X","F","FF"})
generators[3] = LSystemGenerator("Plant by PP & JH", "Y", 25.7, {"Y","YFX[+Y][-Y]","X","X[-FFF][+FFF]FX"})
generators[4] = LSystemGenerator("Plant by PP & JH", "F", 22.5, {"F","FF+[+F-F-F]-[-F+F+F]"})
generators[5] = LSystemGenerator("Plant by PP & JH", "X", 20, {"X","F[+X]F[-X]+X","F","FF"})
generators[6] = LSystemGenerator("RNG test", "F", 10, {"F", "FmF"})
generators[7] = LSystemGenerator("Circle pattern 1 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF"})
generators[8] = LSystemGenerator("Circle pattern 2 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF+FffF"})
generators[9] = LSystemGenerator("Circle pattern 3 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf+fFFf"})
generators[10] = LSystemGenerator("Circle pattern 4 by CL","ffffffffffffffffffffffffffff---F", 22.5,{"F","+++fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf+fFfFf"})
generators[11] = LSystemGenerator("Circle pattern 5 by CL","fffffffffffffffffffffffffffffffffffffffffffff---F", 22.5,{"F","+++fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf+fFfFFfFf"})
generators[12] = LSystemGenerator("Square pattern by CL","fffffffffffffffffff---F", 90,{"F","+++fFfFf+fFfFf+fFfFf+fFfFf"})
generators[13] = LSystemGenerator("Triangle pattern 1 by CL","fffffffffffffffffff---F", 120,{"F","fFfFf+fFfFf+fFfFf+fFfFf"})
generators[14] = LSystemGenerator("Triangle pattern 2 by CL","fffffffffffffffffff---F", 120,{"F","fFfFf+fFfFf+fFfFf"})
generators[15] = LSystemGenerator("Triangle pattern 3 by CL","fffffffffffffffffff---F", 120,{"F","++fFfFf+fFfFf"})
generators[16] = LSystemGenerator("Pentagon pattern 1 by CL","fffffffffffffffffff---F", 72,{"F","FFFFF+FFFFF+FFFFF+FFFFF+FFFFF"})
generators[17] = LSystemGenerator("Hexagon pattern 1 by CL","fffffffffffffffffff---F", 60,{"F","FFFFF+FFFFF+FFFFF+FFFFF+FFFFF+FFFFF"})
generators[18] = LSystemGenerator("Heptagon pattern 1 by CL","fffffffffffffffffff---F", 51.4287,{"F","FFFFF+FFFFF+FFFFF+FFFFF+FFFFF+FFFFF+FFFFF"})
generators[19] = LSystemGenerator("Heptagon pattern 2 by CL","fffffffffffffffffff---F", 51.4287,{"F","FFfFF+FFfFF+FFfFF+FFfFF+FFfFF+FFfFF+FFfFF"})
generators[20] = LSystemGenerator("Heptagon pattern 3 by CL","fffffffffffffffffff---F", 51.4287,{"F","FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF+FfFfF"})

--Start Of Refactor Stuff

startpos = {x=400,y=600}
locus = {}
drawMode = "line"
drawColor = {255,255,255,255}

--[[ Replacement Tables and functions

--replaces actor
turtle = {dir = {x=0,y=0}, pos = {x=0,y=0}}

End of Replacement Tables etc]]


--[[Replacement Functions


function love.draw()
	--TODO: Multiple modes (points, lines, triangles, quads, curves, etc)
	--		Dots/circles/ellipses, lines, polygon/s, rectangles, curves
	--		For all shapes fill/line

	love.graphics.setColor(drawColor)
	
	if(drawMode == "circle")then
		for pos=1, #locus do
			love.graphics.circle("line",locus[pos][1],locus[pos][2],5)
		end
	elseif(drawMode == "dot")then
		for pos=1, #locus do
			love.graphics.circle("fill",locus[pos][1],locus[pos][2],1)
		end
	elseif(drawMode == "line")then
		for pos=1, #locus do
			love.graphics.line(locus[pos][1],locus[pos][2],locus[pos][3],locus[pos][4])
		end
	elseif(drawMode == "box")then
		for pos=1, #locus do
			local w,h = locus[pos][3] - locus[pos][1], locus[pos][4] - locus[pos][2]
			love.graphics.rectangle("line",locus[pos][1],locus[pos][2],w,h)
		end
	end

	love.graphics.print("n="..n,0,0)
	love.graphics.printf(generators[genChoice].name,0,0,800,"center")
	love.graphics.printf(genChoice.."/"..#generators,0,0,800,"right")
end

function love.update(d)
	if(needToUpdate)then
		actor.pos = Vector(startpos.x,startpos.y)
		actor.dir = Vector(0,-5)
		actor.pos:scale(1/scale)
		--Work On framebuffer
    	love.graphics.setCanvas(framebuffer)
		love.graphics.scale(scale,scale)
        love.graphics.clear()
        love.graphics.setBlendMode("alpha")
        --TODO: replace strings as well as individual characters (groups)
		for instruction in state:gmatch"." do
			
			if(instruction == 'f')then
				actor.pos.x = actor.pos.x + actor.dir.x
				actor.pos.y = actor.pos.y + actor.dir.y
			elseif(instruction == 'F')then
				locus[#locus+1] = {actor.pos.x,actor.pos.y,actor.pos.x+actor.dir.x,actor.pos.y+actor.dir.y}
				actor.pos.x = actor.pos.x + actor.dir.x
				actor.pos.y = actor.pos.y + actor.dir.y
			elseif(instruction == '-')then
				local t = {actor.dir.x,actor.dir.y}
				actor.dir.x = t[1] * math.cos(-angle) - t[2] * math.sin(-angle)
				actor.dir.y = t[2] * math.cos(-angle) + t[1] * math.sin(-angle)
			elseif(instruction == '+')then
				local t = {actor.dir.x,actor.dir.y}
				actor.dir.x = t[1] * math.cos(angle) - t[2] * math.sin(angle)
				actor.dir.y = t[2] * math.cos(angle) + t[1] * math.sin(angle)
			elseif(instruction == ']')then
				local t = stack:pop()
				actor.dir = Vector(t[3],t[4])
				actor.pos = Vector(t[1],t[2])
			elseif(instruction == '[')then
				stack:push({actor.pos.x,actor.pos.y,actor.dir.x,actor.dir.y})
			end
		end

		needToUpdate = false
	end
end


End Of Replacement Functions]]

--End of Refactor Stuff

genChoice = 1

actor = Entity()
actor.dim = Vector(5,5)
actor.color = {0,255,255}
stack = Stack()
needToUpdate = true
scale = 1

function choiceChanged()
	angle = math.rad(generators[genChoice].angle)
	initiator = generators[genChoice].initial
	ruleset = generators[genChoice].rules
	actor.pos = startpos
	n = 0
	scale = 1
	stack = Stack()
	needToUpdate = true
	actor.dir = Vector(0,-5)
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
	actor.pos = startpos
	stack = Stack()
	actor.dir = Vector(0,-5)
	state = initiator
	for i=1,t do
		stepForward()
	end
	n = t
	needToUpdate = true
end


function love.load()
	state = initiator
	framebuffer = love.graphics.newCanvas(800, 600)
	choiceChanged()
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(framebuffer)
	love.graphics.setBlendMode("alpha")
	love.graphics.print("n="..n,0,0)
	love.graphics.printf(generators[genChoice].name,0,0,800,"center")
	love.graphics.printf(genChoice.."/"..#generators,0,0,800,"right")
end

function love.update(d)
	if(needToUpdate)then
		--Work On framebuffer
		actor.pos = Vector(startpos.x,startpos.y)
		actor.pos:scale(1/scale)
    	love.graphics.setCanvas(framebuffer)
		love.graphics.scale(scale,scale)
        love.graphics.clear()
        love.graphics.setBlendMode("alpha")
        --TODO: replace strings as well as individual characters
		for instruction in state:gmatch"." do

			if(instruction == 'f')then
				actor.pos = actor.pos + actor.dir
			elseif(instruction == 'F')then
				local t = {actor.pos.x,actor.pos.y}
				actor.pos = actor.pos + actor.dir
				if(drawMode == "line")then
					love.graphics.line(t[1],t[2],actor.pos.x,actor.pos.y)
				elseif(drawMode == "dot")then
					love.graphics.circle("fill",t[1],t[2],1)
				elseif(drawMode == "box")then
					love.graphics.rectangle("line",t[1],t[2],actor.pos.x - t[1],actor.pos.y-t[2])
				end
			elseif(instruction == '-')then
				local lx = actor.dir.x
				local ly = actor.dir.y
				actor.dir.x = lx * math.cos(-angle) - ly * math.sin(-angle)
				actor.dir.y = ly * math.cos(-angle) + lx * math.sin(-angle)
			elseif(instruction == '+')then
				local lx = actor.dir.x
				local ly = actor.dir.y
				actor.dir.x = lx * math.cos(angle) - ly * math.sin(angle)
				actor.dir.y = ly * math.cos(angle) + lx * math.sin(angle)
			elseif(instruction == ']')then
				actor.dir.y = stack:pop()
				actor.dir.x = stack:pop()
				actor.pos.y = stack:pop()
				actor.pos.x = stack:pop()
			elseif(instruction == '[')then
				stack:push(actor.pos.x)
				stack:push(actor.pos.y)
				stack:push(actor.dir.x)
				stack:push(actor.dir.y)
			elseif(instruction == 'm')then
				local rAngle = love.math.random(-90,90)
				local lx = actor.dir.x
				local ly = actor.dir.y
				actor.dir.x = lx * math.cos(rAngle) - ly * math.sin(rAngle)
				actor.dir.y = ly * math.cos(rAngle) + lx * math.sin(rAngle)
			end
		end
		--Back to default framebuffer (ie. the screen)
    	love.graphics.setCanvas()
		needToUpdate = false
		actor.dir = Vector(0,-5)
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

function love.threaderror(thread, errorstr)
	print("Thread error: " .. errorstr)
end