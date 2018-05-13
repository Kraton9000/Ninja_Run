require "30log-global"

Player = class("Player")

function Player:init(character, stance, stanceLimit, x, y, spriteSpeed, spriteTimer)
	self.character = character
	self.stance = stance
	self.stanceLimit = stanceLimit
	self.stanceCount = 1
	self.x = x
	self.y = y
	self.spriteSpeed = spriteSpeed
	self.spriteTimer = spriteTimer
	self.sprite = love.graphics.newImage("Sprites/"..self.character..self.stance..self.stanceCount..".png")
	self.width = self.sprite:getWidth()
	self.height = self.sprite:getHeight()
	self:updateHitbox()
end

function Player:updateStance(stance, stanceLimit)
	if love.filesystem.exists("Hitboxes/".."OS"..self.character..self.stance..".txt") then
		local offset = love.filesystem.read("Hitboxes/".."OS"..self.character..self.stance..".txt")
		self.x = self.x + string.sub(offset, 1, 3)
		self.y = self.y + string.sub(offset, 4, 6)
	end
	self.stance = stance
	self.stanceLimit = stanceLimit
	self.stanceCount = 0
	local spriteLoop = self:incrementSprite()
	self:updateHitbox()
	if love.filesystem.exists("Hitboxes/".."OS"..self.character..self.stance..".txt") then
		local offset = love.filesystem.read("Hitboxes/".."OS"..self.character..self.stance..".txt")
		self.x = self.x - string.sub(offset, 1, 3)
		self.y = self.y - string.sub(offset, 4, 6)
	end
	return spriteLoop

end

function Player:incrementSprite()
	local spriteLoop = false
	self.stanceCount = self.stanceCount + 1
	if self.stanceCount > self.stanceLimit then
		self.stanceCount = 1
	end
	local currentHeight = self.y + self.height
	self.sprite = love.graphics.newImage("Sprites/"..self.character..self.stance..self.stanceCount..".png")
	self.width = self.sprite:getWidth()
	self.height = self.sprite:getHeight()
	self.y = currentHeight - self.height
	if self.stanceCount == self.stanceLimit then
		spriteLoop = true
	end
	return spriteLoop

end

function Player:updateHitbox()
	if love.filesystem.exists("Hitboxes/".."HB"..self.character..self.stance..self.stanceCount..".txt") then
		local hitbox = love.filesystem.read("Hitboxes/".."HB"..self.character..self.stance..self.stanceCount..".txt")
		self.hitX = self.x + string.sub(hitbox, 1, 3)
		self.hitY = self.y + string.sub(hitbox, 4, 6)
		self.hitWidth = self.width - string.sub(hitbox, 7, 9) - string.sub(hitbox, 1, 3)
		self.hitHeight = self.height - string.sub(hitbox, 10, 12) - string.sub(hitbox, 4, 6)
	else
		self.hitX = self.x
		self.hitY = self.y
		self.hitWidth = self.width
		self.hitHeight = self.height
	end
end

function Player:hitTest(enemy)
	return self.hitX < enemy.hitX + enemy.hitWidth and enemy.hitX < self.hitX + self.hitWidth and self.hitY < enemy.hitY + enemy.hitHeight and enemy.hitY < self.hitY + self.hitHeight
end