Grid = Entity:extend()

function Grid:new(dimensions, grid, position, color)
	self.pos = position or Vector(0,0)
	self.dim = dimensions or Vector(0,0)
	self.griddim = grid or Vector(0,0)
	self.color = color or {0,0,0}
	self.data = {}
end

function Grid:draw()
	love.graphics.setColor(self.color)
	for i=0, self.dim.x do
		for j=0, self.dim.y do
			local v = i*self.dim.x+j --(x*width+y)
			if(self.data[v] > 0)then
    			love.graphics.rectangle("fill", i * self.griddim, j * self.griddim, self.griddim.x, self.griddim.y)
    		end
    	end
	end
end