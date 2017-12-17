--! 2D Vector Class
Vector = Object:extend()

function Vector:new(x,y)
	self.x = x or 0
	self.y = y or 0
end

function Vector:__add(vec2)
	out = Vector()
	out.x = self.x + vec2.x
	out.y = self.y + vec2.y
	return out
end

function Vector:__mul(vec2)
--	feel like this is Mathematically incorrect but meh
	out = Vector(self.x*vec2.x,self.y*vec2.y)
	return out
end

function Vector:__sub(vec2)
	out = Vector()
	out.x = self.x - vec2.x
	out.y = self.y - vec2.y
	return out
end

function Vector:__lt(vec2)
	return (self:getLength() < vec2:getLength())
end

function Vector:__eq(vec2)
	return (self.x == vec2.x and self.y == vec2.y)
end

function Vector:getCopy()
	return Vector(self.x,self.y)
end

function Vector:scale(sv)
	self.x = self.x * sv
	self.y = self.y * sv
end 

function Vector:normalize()
	length = self:getLength()
	self.x = self.x / length
	self.y = self.y / length
end

function Vector:getLength()
	return math.sqrt((self.x * self.x) + (self.y * self.y))
end