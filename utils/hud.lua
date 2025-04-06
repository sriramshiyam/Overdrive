hud = {}

function hud:load()
    self.outlineColor = { 0, 0, 0 }
    self.outlineColorDegree = 0
    self.red_vector = { 1, 0 }
    self.green_vector = { math.cos(120 * math.pi / 180), math.sin(120 * math.pi / 180) }
    self.blue_vector = { math.cos(240 * math.pi / 180), math.sin(240 * math.pi / 180) }
    self.bx = 0
    self.by = 0
end

function hud:update(dt)
    self.outlineColorDegree = self.outlineColorDegree + dt * 200

    local radian = self.outlineColorDegree * math.pi / 180
    local cx, cy = unpack({ math.cos(radian), math.sin(radian) })

    local rx, ry = unpack(self.red_vector)
    self.outlineColor[1] = ((cx * rx + cy * ry) + 1) / 2

    local gx, gy = unpack(self.green_vector)
    self.outlineColor[2] = ((cx * gx + cy * gy) + 1) / 2

    local bx, by = unpack(self.blue_vector)
    self.outlineColor[3] = ((cx * bx + cy * by) + 1) / 2
end

function hud:draw()
    local r, g, b = unpack(self.outlineColor)
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
