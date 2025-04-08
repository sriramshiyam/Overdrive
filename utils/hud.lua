hud = {}

function hud:load()
    self.color = { 0, 0, 0 }
    self.color_degree = 0
    self.bx = 0
    self.by = 0
end

function hud:update(dt)
    update_color(self, dt, 200)
end

function hud:draw()
    local r, g, b = unpack(self.color)
    love.graphics.setColor(r, g, b, 1)

    local start_pos, end_pos

    for i = 1, 4 do
        if i == 1 then
            start_pos, end_pos = { 20, 30 }, { 25, 30 }
        elseif i == 2 then
            start_pos, end_pos = { 20, canvas_height - 30 }, { 25, canvas_height - 30 }
        elseif i == 3 then
            start_pos, end_pos = { 20, 30 }, { 20, 35 }
        else
            start_pos, end_pos = { canvas_width - 20, 30 }, { canvas_width - 20, 35 }
        end

        local x1, y1 = unpack(start_pos)
        local x2, y2 = unpack(end_pos)

        while true do
            if i <= 2 then
                if x2 > canvas_width - 20 then
                    break
                end
            else
                if y2 > canvas_height - 30 then
                    break
                end
            end
            love.graphics.line(x1, y1, x2, y2)
            if i <= 2 then
                x1 = x1 + 10
                x2 = x2 + 10
            else
                y1 = y1 + 10
                y2 = y2 + 10
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end
