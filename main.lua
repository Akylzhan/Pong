push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1280

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()
	
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Pong Pong')

	math.randomseed(os.time())

	-- FONT SETTINGS
	smallFont = love.graphics.newFont('font.ttf', 8)
	love.graphics.setFont(smallFont)

	scoreFont = love.graphics.newFont('font.ttf', 32)
	largeFont = love.graphics.newFont('font.ttf', 16)
	--
	opening = love.audio.newSource("opening.ogg", "stream")
	opening:setVolume(0.7)
	opening:play()

    touchSound = {
        [1] = love.audio.newSource("touch1.wav", "stream"),
        [2] = love.audio.newSource("touch2.wav", "stream"),
        [3] = love.audio.newSource("touch3.wav", "stream"),
        [4] = love.audio.newSource("touch4.wav", "stream"),
        [5] = love.audio.newSource("touch5.wav", "stream")
    } 
	-- WINDOW SETTINGS
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true
	})
	--

	servingPlayer = 1

	player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)

  	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
	
	player1Score = 0
	player2Score = 0

	--


	gameState = 'start'
end 

function love.resize(w, h) 
	push:resize(w, h)
end
function love.update(dt)
	-- player 1 movement
	if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
        
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
    end

    elseif gameState == 'play' then
   		ball:update(dt)
        if ball:collides(player1) then
            touchSound[math.random(5)]:play()
            ball.dx = -ball.dx * 1.08
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        if ball:collides(player2) then
            touchSound[math.random(5)]:play()
            ball.dx = -ball.dx * 1.08
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end


    	if ball.x < 0 then
	        servingPlayer = 1
    	    player2Score = player2Score + 1
	        if player2Score == 10 then
        		winningPlayer = 2
    	    	gameState = 'done'
	        else
        		gameState = 'serve'
        		ball:reset()
    	    end
	    end

	    if ball.x > VIRTUAL_WIDTH then
	        servingPlayer = 2
        	player1Score = player1Score + 1
    	    if player1Score == 10 then
	        	winningPlayer = 1
        		gameState = 'done'
        	else 
        		gameState = 'serve'
        		ball:reset()
        	end
    	end
	end	

        -- player 2 movement
    if ball.y < player2.y then
        player2.dy = -PADDLE_SPEED
    elseif ball.y - 4 > player2.y then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)
end


-- quit the game by pressing ESC
function love.keypressed(key) 
	if key == 'escape' then
		love.event.quit()

	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			 gameState = 'serve'

            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
	end

end
--


function love.draw()

    push:apply('start')

 	love.graphics.clear(50/255, 50/255, 50/255, 255/255)    

    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Hello, World!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
    elseif gameState == 'done' then
    	love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 4 + 16, VIRTUAL_HEIGHT / 4)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH *3/4 - 32, VIRTUAL_HEIGHT / 4)


    player1:render()
    player2:render()

    ball:render()

    displayFPS()
    push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0/255, 255/255, 0/255, 255/255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10) 	
end
