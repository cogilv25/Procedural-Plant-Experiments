--Written by Calum Lindsay.

--Super simple barebones stack class

Stack = Object:extend()

function Stack:new()
	self.data = {}
end

function Stack:push(dat)
	self.data[#self.data+1] = dat
end

function Stack:pop()
	local t = self.data[#self.data]
	self.data[#self.data] = nil
	return t
end