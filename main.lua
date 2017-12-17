--http://algorithmicbotany.org/papers/lsfp.pdf <-- Reference
Object = require "lib/classic"
require "lib/stack"
require "base/vector"
require "base/entity"
n = 0
genChoice = 1
angles = {22.5,45,25.7,22.5,25.7,22.5,20}
initiators = {"RFT","R","F","X","Y","F","X"}
generators = {{"R","RF","T","JA","J","[++RFFT][-RFFT]","A","F+JB","B","FFF---J"},
			{"R","FR-U","U","FF--D","D","FF++U"},
			{"F","F[+F]F[-F]F"},
			{"X","F-[[X]+X]+F[+FX]-X","F","FF"},
			{"Y","YFX[+Y][-Y]","X","X[-FFF][+FFF]FX"},
			{"F","FF+[+F-F-F]-[-F+F+F]"},
			{"X","F[+X]F[-X]+X","F","FF"}}
--PP = Przemyslaw Prusinkiewicz
--JH = James Hanan

names = {"tree-1","coil","Plant by PP & JH","Plant by PP & JH","Plant by PP & JH","Plant by PP & JH","Plant by PP & JH","Plant by PP & JH"}
angle = math.rad(angles[genChoice])
initiator = initiators[genChoice]
generator = generators[genChoice]
actor = Entity();actor.dim = Vector(5,5);actor.pos = Vector(400,600)
startpos = Vector(400,600)
actor.color = {255,255,255}
actor.dir = Vector(0,-5)
stack = Stack()
needToUpdate = true
scale = 1

function choiceChanged()
	angle = math.rad(angles[genChoice])
	initiator = initiators[genChoice]
	generator = generators[genChoice]
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
		local lgen = #generator / 2
		for i=1,lgen do
			if(instruction == generator[i*2-1])then
				state = state .. generator[i*2]
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
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(framebuffer)
	love.graphics.setBlendMode("alpha")
	love.graphics.print("n="..n,0,0)
	love.graphics.printf(names[genChoice],0,0,800,"center")
	love.graphics.printf(genChoice.."/"..#names-1,0,0,800,"right")
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
		stepBack()
	end
	if(key == "right" or key == "d")then
		--step forward
		stepForward()
	end
	if(key == "down" or key == "s")then
		scale = scale * 0.75
		needToUpdate = true
	end
	if(key == "up" or key == "w")then
		scale = scale*1.33333
		needToUpdate = true
	end
	if(key == ".")then
		genChoice = genChoice + 1
		choiceChanged()
	end
	if(key == ",")then
		genChoice = genChoice - 1
		choiceChanged()
	end
end