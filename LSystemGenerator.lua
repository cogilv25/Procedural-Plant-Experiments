Object = require "lib/thirdparty/classic/classic"

LSystemGenerator = Object:extend()

function LSystemGenerator:new(name, initialValue, angle, rules)
	assert(type(rules) == "table")
	self.initial = initialValue
	self.angle = angle
	self.rules = rules
	self.name = name
end

