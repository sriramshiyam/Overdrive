require "utils.hud"
require "sprites.player"

canvas_width = 1024
canvas_height = 768

local canvas
canvas_offset_x = 0
canvas_offset_y = 0
scale = 1
sleep = 0

function love.load()
    love.window.setTitle("Overdrive")
    love.window.setMode(800, 600, { resizable = true })
    love.window.maximize()
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas = love.graphics.newCanvas(canvas_width, canvas_height)
    for i = 1, #arg do
        if arg[i] == "mon-2" then
            love.window.setPosition(0, 0, 2)
        end
    end
    hud:load()
    player:load()
end

function love.update(dt)
    hud:update(dt)
    player:update(dt)
    love.timer.sleep(sleep)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    hud:draw()
    player:draw()
    love.graphics.setCanvas()
    love.graphics.clear()
    love.graphics.draw(canvas, canvas_offset_x, canvas_offset_y, 0, scale, scale)
end

function love.resize(window_width, window_height)
    scale = math.min(window_width / canvas_width, window_height / canvas_height)
    canvas_offset_x = (window_width - canvas_width * scale) / 2
    canvas_offset_y = (window_height - canvas_height * scale) / 2
end
