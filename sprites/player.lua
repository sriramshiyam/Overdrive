player = {}

function player:load()
    self.texture = love.graphics.newImage("res/image/player.png")
    self.position = { x = 0, y = 0 }
    self.direction = { x = 0, y = 0 }
    self.origin = { x = 0, y = 0 }
    self.speed = 600
    self.crosshair_texture = love.graphics.newImage("res/image/crosshair.png")
    self.crosshair_vector = { x = 100, y = 100 }
    self.crosshair_rotation = 0
    self.bullets = {}
    self.shoot_timer = 0
end

function player:update(dt)
    self.direction.x, self.direction.y = 0, 0

    if love.keyboard.isDown("d") then
        self.direction.x = 1
    elseif love.keyboard.isDown("a") then
        self.direction.x = -1
    end

    if love.keyboard.isDown("s") then
        self.direction.y = 1
    elseif love.keyboard.isDown("w") then
        self.direction.y = -1
    end

    if self.direction.x ~= 0 and self.direction.y ~= 0 then
        self.direction.x = self.direction.x * math.cos(math.pi / 4)
        self.direction.y = self.direction.y * math.sin(math.pi / 4)
    end

    if self.direction.x ~= 0 or self.direction.y ~= 0 then
        self.position.x = self.position.x + self.direction.x * self.speed * dt
        self.position.y = self.position.y + self.direction.y * self.speed * dt
        self.origin.x = self.position.x + self.texture:getWidth() / 2
        self.origin.y = self.position.y + self.texture:getHeight() / 2
    end

    if love.keyboard.isDown("space") then
        self:shoot(dt)
    else
        self.shoot_timer = 0
    end

    self:update_bullets(dt)
    self:update_crosshair(dt)
end

function player:update_crosshair(dt)
    self.crosshair_rotation = self.crosshair_rotation + dt * 300
end

function player:update_bullets(dt)
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet.rect.x = bullet.rect.x + bullet.direction.x * bullet.speed * dt
        bullet.rect.y = bullet.rect.y + bullet.direction.x * bullet.speed * dt

        if (bullet.rect.x > canvas_width + 200) or (bullet.rect.x < -200) or
            (bullet.rect.y > canvas_height + 200) or (bullet.rect.y < -200) then
            table.remove(self.bullets, i)
        end
    end
end

function player:shoot(dt)
    self.shoot_timer = self.shoot_timer - dt
    if self.shoot_timer < 0 then
        self.shoot_timer = 0.35
        local length = math.sqrt(self.crosshair_vector.x ^ 2 + self.crosshair_vector.y ^ 2)
        local direction = { x = self.crosshair_vector.x / length, y = self.crosshair_vector.y / length }
        table.insert(self.bullets, {
            direction = direction,
            rect = { x = self.origin.x + direction.x * 40 - 10, y = self.origin.y + direction.y * 40 - 10, width = 20, height = 20 },
            speed = 1200
        })
    end
end

function player:draw()
    love.graphics.draw(self.texture, self.position.x, self.position.y)
    self:draw_crosshair()
    self:draw_bullets()
end

function player:draw_crosshair()
    local pos = { x = self.origin.x + self.crosshair_vector.x, y = self.origin.y + self.crosshair_vector.y }
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", pos.x - 2, pos.y - 2, 4, 4)

    love.graphics.draw(self.crosshair_texture, pos.x, pos.y, self.crosshair_rotation * math.pi / 180, 1, 1,
        self.crosshair_texture:getWidth() / 2,
        self.crosshair_texture:getHeight() / 2)
end

function player:draw_bullets()
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, #self.bullets do
        local rect = self.bullets[i].rect
        love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height)
    end
end
