require "30log-global"
require "Player"

Enemy = Player:extend("Enemy")

function Enemy:init(character, stance, stanceLimit, x, y, spriteSpeed, spriteTimer, dx, dy, orient)
	Enemy.super.init(self, character, stance, stanceLimit, x, y, spriteSpeed, spriteTimer)
	self.dx = dx
	self.dy = dy
	self.orient = orient
	self:updateHitbox()
end

function Enemy:translate(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Enemy:updateHitbox()
	if self.orient == 1 or love.filesystem.exists("HB"..self.character..self.stance..self.stanceCount..".txt") == false then
		Enemy.super.updateHitbox(self)
	else
		local hitbox = love.filesystem.read("HB"..self.character..self.stance..self.stanceCount..".txt")
		self.hitX = self.x + string.sub(hitbox, 7, 9)
		self.hitY = self.y + string.sub(hitbox, 4, 6)
		self.hitWidth = self.width - string.sub(hitbox, 1, 3)
		self.hitHeight = self.height - string.sub(hitbox, 10, 12) - string.sub(hitbox, 4, 6)
	end
end