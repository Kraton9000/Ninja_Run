require "30log-global"

Backdrop = class("Backdrop")

function Backdrop:init(image, width, speed)
	self.image = love.graphics.newImage(image)
	self.width = width
	self.speed = speed
	self.x = 0
	self.orient = 1
	self.imageCount = 0
	self.limboZone = false
	self.fillWidth = (math.floor(love.graphics.getWidth() / self.width) + 1) * self.width
	for i = 1, self.fillWidth / self.width + 1 do
		self.imageCount = self.imageCount + 1
	end
end

function Backdrop:scroll()
	self.x = self.x - self.speed
	if self.x <= love.graphics.getWidth() - self.fillWidth and self.limboZone == false then
		self.imageCount = self.imageCount + 1
		self.limboZone = true
	end
	if self.x <= self.width * -1 then
		self.imageCount = self.imageCount - 1
		self.orient = self.orient * -1
		self.x = 0
		self.limboZone = false
	end
end

function Backdrop:draw()
	for i = self.imageCount, 1, -1 do
		local flip = (i % 2) * self.orient - ((i % 2 - 1) * -1 * self.orient)
		love.graphics.draw(self.image, self.x + self.width * (i-1), 0, 0, flip, 1, self.width * ((flip - 1) / -2), 0)
	end
end

function Backdrop:drawTest()
	love.graphics.draw(self.image, self.x, 0)
end