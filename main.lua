--Author: Maduvan Kasi
--Date: Janurary 28th, 2017
--Title: Naruto: Ninja Run

--To-Do:
-- Game Feel
--	Tenten Sluggish
-- Game Lag
--	Image Loading
--		Pontentially Fixed (/w/ Preloaded Sprites)
--			Maybe enemies + backdrops??? | <-- Doesnt make much sense tho
-- Game Mechanics
--	Screen Boundary?
--	Move Timer?
-- Conditions
--	Loss - Enemy Miss
-- UI
--	All of It

--Imports
require "Player"
require "Enemy"
require "Backdrop"

--Update Character Function
function updateCharacter(character)
	activePlayer.character = character
	inAir = true
end

--Cease Attack Function
function ceaseAttack(stance, stanceLimit)
	updatePlayerStance(stance, stanceLimit)
	attacking = false
end

--Update Player Stance Function
function updatePlayerStance(stance, stanceLimit)
	local spriteLoop = activePlayer:updateStance(stance, stanceLimit)
	activePlayer.spriteTimer = dtCount
	return spriteLoop
end

--Preload Stance Function
function preloadStance()
	for i = 1, activePlayer.stanceCount do
		love.graphics.newImage("Sprites/"..activePlayer.character..activePlayer.stance..activePlayer.stanceCount..".png")
	end
end

--Preload Character Function
function preloadCharacter(attackCount)
	activePlayer.stance = "Run"
	activePlayer.stanceCount = 6
	preloadStance()
	activePlayer.stance = "JumpUp"
	activePlayer.stanceCount = 1
	preloadStance()
	activePlayer.stance = "JumpDown"
	activePlayer.stanceCount = 1
	preloadStance()
	activePlayer.stance = "Attack"
	activePlayer.stanceCount = attackCount
	preloadStance()
	activePlayer.stance = "AttackDown"
	activePlayer.stanceCount = 1
	preloadStance()
	activePlayer.stance = "Hurt"
	activePlayer.stanceCount = 1
	preloadStance()
	activePlayer.stance = "DeadUp"
	activePlayer.stanceCount = 1
	preloadStance()
	activePlayer.stance = "DeadDown"
	activePlayer.stanceCount = 2
end

function love.load()

	--Key Control
	rightDown = false
	leftDown = false
	jumped = false
	attacking = false
	stopped = false

	--Timers
	dtCount = 0
	enemyTimer = 0
	
	--Physics
	gravity = 0
	inAir = true

	--Graphics
	spriteLooped = false
	groundHeight = 283

	--Classes
	activePlayer = Player("Lee", "JumpUp", 1, 40, 0, 0.07, 0)
	backdrop = Backdrop("backdrop.png", 696, 20)

	--Enemy Control
	enemyCount = 0
	enemies = {}
	enemyTypes = {Enemy("Zetsu", "Run", 6, 800, groundHeight - 56, 0.07, 0, -300, 0, -1), Enemy("Clay", "Run", 6, 800, 50, 0.07, 0, -300, 0, -1)}

	--Game State
	playerDead = false

	--Level Info
	level = love.filesystem.read("LVL1.txt")
	enemySpawn = tonumber(string.sub(level, 1, string.find(level, " ") - 1))
	enemyType = tonumber(string.sub(level, string.find(level, " ") + 1, string.find(level, " ") + 1))
	lineBreak = (string.find(level, "\n"))

	--PreLoad Sprites
	preloadCharacter(9)
	activePlayer.character = "Neji"
	preloadCharacter(8)
	activePlayer.character = "Tenten"
	preloadCharacter(9)
	activePlayer.character = "Lee"
	activePlayer.stance = "JumpUp"
	activePlayer.stanceCount = 1

end

function love.update(dt)

	--Pause Control
	if stopped == false then

		--Increment Main Timer
		dtCount = dtCount + dt

		--Increment Sprites
		if dtCount - activePlayer.spriteTimer >= activePlayer.spriteSpeed then
			spriteLooped = activePlayer:incrementSprite()
			activePlayer.spriteTimer = dtCount
		end
		if enemyCount > 0 then
			if dtCount - enemies[1].spriteTimer >= enemies[1].spriteSpeed then
				for i = enemyCount, 1, -1 do
					enemies[i]:incrementSprite()
				end
				enemies[1].spriteTimer = dtCount
			end
		end

		if playerDead == false then

			--Spawn Enemies
			if dtCount - enemyTimer >= enemySpawn then
				enemyCount = enemyCount + 1
				if enemyCount > 1 then
					enemies[enemyCount] = Enemy(enemyTypes[enemyType].character, "Run", 6, 800, enemyTypes[enemyType].y, 0.07, enemies[1].spriteTimer, -300, 0, -1)
				else
					enemies[enemyCount] = Enemy(enemyTypes[enemyType].character, "Run", 6, 800, enemyTypes[enemyType].y, 0.07, 0, -300, 0, -1)
				end
				enemyTimer = dtCount

				if lineBreak ~= nil then
					level = string.sub(level, lineBreak + 1)
					enemySpawn = tonumber(string.sub(level, 1, string.find(level, " ") - 1))
					enemyType = tonumber(string.sub(level, string.find(level, " ") + 1, string.find(level, " ") + 1))
					lineBreak = (string.find(level, "\n"))
				else
					enemySpawn = 9999 -- Same solution as Stop Sprite Increments
					print("You've defeated the level! Now what?!")
				end

			end

			--Translate Player
			if attacking ~= true then
				if rightDown == true then
					activePlayer.x = activePlayer.x + 350 * dt
				elseif leftDown == true then
					activePlayer.x = activePlayer.x - 300 * dt
				end
				activePlayer.x = activePlayer.x - 100 * dt
			end

			--Backdrop Movement
			backdrop:scroll()

		else

			--Stop Sprite Increments
			if activePlayer.stance == "DeadDown" and spriteLooped == true then
				activePlayer.spriteTimer = dtCount --Resets on Window Move | Find more elegant solution than 10000000000000000000000000
			end

		end

		--Air Control
		if jumped == true or inAir == true then

			--Jump Momentum
			if jumped == true then
				inAir = true
				activePlayer.y = activePlayer.y - 450 * dt
			end

			--Gravity
			if activePlayer.y < groundHeight - activePlayer.height then
				activePlayer.y = activePlayer.y + gravity * dt
				gravity = gravity + 20

			--Ground Stance Update
			else
				activePlayer.y = groundHeight - activePlayer.height
				gravity = 0
				jumped = false
				inAir = false
				if playerDead == false then
					updatePlayerStance("Run", 6)
				else

					--Death Bounce
					if activePlayer.stance == "Hurt" then
						updatePlayerStance("DeadUp", 1)
						jumped = true
						gravity = 250
					else
						spriteLooped = updatePlayerStance("DeadDown", 2)
					end

				end

			end

			--Jump Apex Stance Update
			if activePlayer.stance == "JumpUp" and gravity > 450 then
				updatePlayerStance("JumpDown", 1)
			end
			
		end

		--Attack Animations
		if attacking == true then

			--Lee
			if activePlayer.character == "Lee" then
				if spriteLooped == true then
					ceaseAttack("Run", 6)
				else
					activePlayer.x = activePlayer.x + 500 * dt
				end

			--Neji
			elseif activePlayer.character == "Neji" then
				if spriteLooped == true then
					ceaseAttack("Run", 6)
				else
					activePlayer.x = activePlayer.x - 550 * dt
				end

			--Tenten
			elseif activePlayer.character == "Tenten" then
				if spriteLooped == true then
					ceaseAttack("AttackDown", 1)
					inAir = true
				else
					activePlayer.y = activePlayer.y - 300 * dt
				end
			end

		end

		--Update Hitbox
		activePlayer:updateHitbox()

		--Enemy Control
		for i = enemyCount, 1, -1 do

			--Translate Position
			enemies[i]:translate(dt)

			--Update Hitbox
			enemies[i]:updateHitbox()

			--Boundary Check
			if enemies[i].x <= 0 - enemies[i].width or enemies[i].x >= 800 then
				for j = i, enemyCount do
					enemies[j] = enemies[j + 1]
				end
				enemyCount = enemyCount - 1
			else

				--Player HitTest
				if enemies[i]:hitTest(activePlayer) then
					--stopped = true
					if attacking == true then
						enemies[i]:updateStance("Hurt", 1)
						if activePlayer.hitX < enemies[i].hitX then
							enemies[i].dx = 700
							enemies[i].orient = -1
						else
							enemies[i].dx = -700
							enemies[i].orient = 1
						end
					else
						if playerDead ~= true then
							playerDead = true
							updatePlayerStance("Hurt", 1)
							jumped = true
							activePlayer.spriteSpeed = 0.22
						end
					end
				end

			end

		end

	end

end

function love.draw()

	--Draw Backdrop
	backdrop:draw()

	--Test Field Above Player
	--love.graphics.setColor(255, 0, 0)
	--love.graphics.print(, activePlayer.x + activePlayer.width / 2, activePlayer.y - 15)
	--love.graphics.setColor(255, 255, 255)

	--Sprite Hitbox
	--love.graphics.setColor(255, 0, 0)
	--love.graphics.rectangle("fill", activePlayer.x, activePlayer.y, activePlayer.width, activePlayer.height)

	--Player Hitbox
	--love.graphics.setColor(255, 255, 255)
	--love.graphics.rectangle("fill", activePlayer.hitX, activePlayer.hitY, activePlayer.hitWidth, activePlayer.hitHeight)

	--Draw Enemies
	for i = 1, enemyCount do
		--Enemy Hitbox
		--love.graphics.setColor(0, 0, 255)
		--love.graphics.rectangle("fill", enemies[i].hitX, enemies[i].hitY, enemies[i].hitWidth, enemies[i].hitHeight)
		--love.graphics.setColor(255, 255, 255)
		love.graphics.draw(enemies[i].sprite, enemies[i].x, enemies[i].y, 0, enemies[i].orient, 1, enemies[i].width * ((enemies[i].orient - 1) / -2), 0)
	end

	--Draw Player
	love.graphics.draw(activePlayer.sprite, activePlayer.x, activePlayer.y)

end

function love.keypressed(key)

	--Restart
	if key == "r" then
		love.load()
	end

	--Pause
	if key == "lctrl" then
		if stopped == true then
			stopped = false
		else
			stopped = true
		end
	end

	if playerDead == false then

		--Move Right
		if key == "right" then
			rightDown = true
		end

		--Move Left
		if key == "left" then
			leftDown = true
		end

		if stopped == false then

			if attacking == false then
				if inAir == false then

					--Jump
					if key == "up" then
						jumped = true
						updatePlayerStance("JumpUp", 1)
					end

					--Attack
					if key == "space" then
						if activePlayer.character == "Lee" then
							spriteLooped = updatePlayerStance("Attack", 9)
						elseif activePlayer.character == "Neji" then
							spriteLooped = updatePlayerStance("Attack", 8)
						elseif activePlayer.character == "Tenten" then
							spriteLooped = updatePlayerStance("Attack", 9)
						end
						attacking = true
					end

				end

				--Change Character
				if key == "1" then
					updateCharacter("Lee")
				elseif key == "2" then
					updateCharacter("Neji")
				elseif key == "3" then
					updateCharacter("Tenten")
				end

			end

		end

	end

end

function love.keyreleased(key)

	if key == "right" then
		rightDown = false
	end

	if key == "left" then
		leftDown = false
	end

end