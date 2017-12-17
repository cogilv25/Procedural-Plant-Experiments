--http://algorithmicbotany.org/papers/lsfp.pdf <-- Reference
Object = require "lib/classic"
require "lib/stack"
require "base/vector"
require "base/entity"
n = 0
angle = math.rad(25.7)
initiator = "F"
generator = {"F","F[+F]F[-F]F"}
actor = Entity();actor.dim = Vector(5,5);actor.pos = Vector(100,100)
actor.color = {255,255,255}
actor.dir = Vector(0,-5)
actor.stack = Stack()
needToUpdate = true
scale = 1
trans = Vector(400,300)
stack = Stack()

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


function love.load()
	state = initiator
	framebuffer = love.graphics.newCanvas(800, 600)
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(framebuffer)
end

function love.update(d)
	if(needToUpdate)then
		--Work On framebuffer
    	love.graphics.setCanvas(framebuffer)
		love.graphics.scale(scale,scale)
        love.graphics.clear()
        love.graphics.setBlendMode("alpha")
        love.graphics.translate(trans.x,trans.y)

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
		actor.pos = Vector(100,100)
		actor.dir = Vector(0,-5)
	end
end

function love.keypressed(key)
	if(key == "escape")then
		love.window.close()
	end
	if(key == "left" or key == "a")then
		--TODO: step back
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
		trans:scale(2)
		needToUpdate = true
	end
end