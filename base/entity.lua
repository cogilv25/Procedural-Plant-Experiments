--! Entity Class
require "base/vector"

Entity = Object:extend()
function Entity:new()
--	Position (X, Y)
	self.pos = Vector(0,0)
--	Dimensions (Width, Height)
	self.dim = Vector(30,30)
--	Color (Red, Green, Blue)
	self.color = {0,0,0}
end

function Entity:draw()
	love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.dim.x, self.dim.y)
end