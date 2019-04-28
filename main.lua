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

require "LSystemGenerator"
require "lib/containers/stack"
require "lib/game/vector"
require "lib/game/entity"
n = 0

--PP = Przemyslaw Prusinkiewicz
--JH = James Hanan
--CL = Calum Lindsay
generators = {}
generators[1] = LSystemGenerator("Tree 1 by CL", "RFT", 22.5, {"R","RF","T","JA","J","[++RFFT][-RFFT]","A","F+JB","B","FFF---J"})
generators[2] = LSystemGenerator("Rhombus? by CL", "R", 45, {"R","FR-U","U","FF--D","D","FF++U"})
generators[3] = LSystemGenerator("Plant by PP & JH", "F", 25.7, {"F","F[+F]F[-F]F"})
generators[4] = LSystemGenerator("Plant by PP & JH", "X", 22.5, {"X","F-[[X]+X]+F[+FX]-X","F","FF"})
generators[5] = LSystemGenerator("Plant by PP & JH", "Y", 25.7, {"Y","YFX[+Y][-Y]","X","X[-FFF][+FFF]FX"})
generators[6] = LSystemGenerator("Plant by PP & JH", "F", 22.5, {"F","FF+[+F-F-F]-[-F+F+F]"})
generators[7] = LSystemGenerator("Plant by PP & JH", "X", 20, {"X","F[+X]F[-X]+X","F","FF"})
generators[8] = LSystemGenerator("RNG test", "F", 10, {"F", "FmF"})

genChoice = 1

actor = Entity()
actor.dim = Vector(5,5)
actor.color = {0,255,255}
startpos = Vector(400,600)
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
	for instruction in oldState:gmatch"." do
		local lgen = #ruleset / 2
		for i=1,lgen do
			if(instruction == ruleset[i*2-1])then
				state = state .. ruleset[i*2]
				break
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
		actor.pos = startpos:getCopy()
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
				love.graphics.line(t[1],t[2],actor.pos.x,actor.pos.y)
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