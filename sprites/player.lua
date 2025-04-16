player = {}

function player:load()
    self.texture = love.graphics.newImage("res/image/player.png")
    self.position = { x = 0, y = 0 }
    self.direction = { x = 0, y = 0 }
    self.speed = 600
    self.crosshair_texture = love.graphics.newImage("res/image/crosshair.png")
    self.origin = {
        x = self.position.x + self.crosshair_texture:getWidth() / 2,
        y = self.position.y + self.crosshair_texture:getHeight() / 2
    }
    self.crosshair_vector = { x = math.cos(math.pi / 4), y = math.cos(math.pi / 4) }
    self.crosshair_length = 120
    self.crosshair_rotation = 0
    self.crosshair_speed = 200
    self.bullets = {}
    self.shoot_timer = 0
    self.enemy_vector = { x = 0, y = 0 }
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

    local nearest_enemy = nil
    local nearest_length = canvas_width

    for i = 1, #enemies.list do
        local enemy = enemies.list[i]
        if enemy.is_spawned then
            local length = vector_length(enemy.origin.x - self.origin.x, enemy.origin.y - self.origin.y)
            if length < nearest_length then
                nearest_length = length
                nearest_enemy = enemy
            end
        end
    end

    if nearest_enemy ~= nil then
        local enemy_vector = {
            x = nearest_enemy.origin.x - self.origin.x,
            y = nearest_enemy.origin.y - self.origin.y
        }
        local length = vector_length(enemy_vector.x, enemy_vector.y)
        enemy_vector.x = enemy_vector.x / length
        enemy_vector.y = enemy_vector.y / length
        local crosshair_vector = self.crosshair_vector

        local dot_product = crosshair_vector.x * enemy_vector.x + crosshair_vector.y * enemy_vector.y

        if dot_product < 0.9999 then
            local radian = self.crosshair_speed * dt * math.pi / 180
            local cross_product = crosshair_vector.x * enemy_vector.y - crosshair_vector.y * enemy_vector.x

            if cross_product < 0 then
                radian = radian * -1
            end

            crosshair_vector.x, crosshair_vector.y =
                crosshair_vector.x * math.cos(radian) - crosshair_vector.y * math.sin(radian),
                crosshair_vector.x * math.sin(radian) + crosshair_vector.y * math.cos(radian)
        end
    end
end

function player:update_bullets(dt)
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet.rect.x = bullet.rect.x + bullet.direction.x * bullet.speed * dt
        bullet.rect.y = bullet.rect.y + bullet.direction.y * bullet.speed * dt
        update_color(bullet, dt, 200)

        for j = 1, #bullet.sparkles do
            bullet.sparkles[j].x = bullet.sparkles[j].x + bullet.direction.x * bullet.speed * dt
            bullet.sparkles[j].y = bullet.sparkles[j].y + bullet.direction.y * bullet.speed * dt
            update_color(bullet.sparkles[j], dt, 200)
        end

        if (bullet.rect.x > canvas_width + 200) or (bullet.rect.x < -200) or
            (bullet.rect.y > canvas_height + 200) or (bullet.rect.y < -200) then
            table.remove(self.bullets, i)
        end

        local remove = false

        for j = 1, #enemies.list do
            if enemies.list[j].is_spawned then
                local rect1 = enemies.list[j].rect
                local rect2 = bullet.rect

                if ((rect1.x + rect1.width) > rect2.x) and (rect1.x < (rect2.x + rect2.width))
                    and ((rect1.y + rect1.height) > rect2.y) and (rect1.y < (rect2.y + rect2.height)) then
                    remove = true
                    enemies.list[j].is_dead = true
                end
            end
        end

        if remove then
            table.remove(self.bullets, i)
        end
    end
end

function player:shoot(dt)
    self.shoot_timer = self.shoot_timer - dt
    if self.shoot_timer < 0 then
        self.shoot_timer = 0.2

        local position = {
            x = self.origin.x + self.crosshair_vector.x * 40,
            y = self.origin.y +
                self.crosshair_vector.y * 40
        }
        local sparkles = {}
        local crosshair_vector = self.crosshair_vector

        local inverted_direction = {
            x = crosshair_vector.x * math.cos(math.pi) - crosshair_vector.y * math.sin(math.pi),
            y = crosshair_vector.x * math.sin(math.pi) + crosshair_vector.y * math.cos(math.pi)
        }

        local rotated_dir1 = {
            x = crosshair_vector.x * math.cos(math.pi / 2) - crosshair_vector.y * math.sin(math.pi / 2),
            y = crosshair_vector.x * math.sin(math.pi / 2) + crosshair_vector.y * math.cos(math.pi / 2)
        }

        local rotated_dir2 = {
            x = crosshair_vector.x * math.cos(-math.pi / 2) - crosshair_vector.y * math.sin(-math.pi / 2),
            y = crosshair_vector.x * math.sin(-math.pi / 2) + crosshair_vector.y * math.cos(-math.pi / 2)
        }

        local degree = math.random(0, 360)

        for i = 1, 4 do
            local point1 = {
                x = position.x + inverted_direction.x * i * 20 + rotated_dir1.x * 7,
                y = position.y + inverted_direction.y * i * 20 + rotated_dir1.y * 7,
                size = 15 - i * 2
            }
            point1.x, point1.y = point1.x - point1.size / 2, point1.y - point1.size / 2
            point1.color_degree = degree
            point1.color = { 0, 0, 0 }

            table.insert(sparkles, point1)

            local point2 = {
                x = position.x + inverted_direction.x * i * 20 + rotated_dir2.x * 7.5,
                y = position.y + inverted_direction.y * i * 20 + rotated_dir2.y * 7.5,
                size = 15 - i * 2
            }
            point2.x, point2.y = point2.x - point2.size / 2, point2.y - point2.size / 2
            point2.color_degree = degree
            point2.color = { 0, 0, 0 }

            table.insert(sparkles, point2)

            degree = degree + 20
        end

        position.x, position.y = position.x - 12.5, position.y - 12.5
        table.insert(self.bullets, {
            direction = { x = crosshair_vector.x, y = crosshair_vector.y },
            rect = { x = position.x, y = position.y, width = 25, height = 25 },
            speed = 1000,
            sparkles = sparkles,
            color_degree = degree,
            color = { 0, 0, 0 }
        })
    end
end

function player:draw()
    love.graphics.draw(self.texture, self.position.x, self.position.y)
    self:draw_crosshair()
    self:draw_bullets()
end

function player:draw_crosshair()
    local pos = {
        x = self.origin.x + self.crosshair_vector.x * self.crosshair_length,
        y = self.origin.y + self.crosshair_vector.y * self.crosshair_length
    }
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", pos.x - 2, pos.y - 2, 4, 4)

    love.graphics.draw(self.crosshair_texture, pos.x, pos.y, self.crosshair_rotation * math.pi / 180, 1, 1,
        self.crosshair_texture:getWidth() / 2,
        self.crosshair_texture:getHeight() / 2)
end

function player:draw_bullets()
    for i = 1, #self.bullets do
        local bullet = self.bullets[i]
        local r, g, b = unpack(bullet.color)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", bullet.rect.x, bullet.rect.y, bullet.rect.width, bullet.rect.height)
        love.graphics.setColor(1, 1, 1, 1)
        for j = 1, #bullet.sparkles do
            local x, y, size = bullet.sparkles[j].x, bullet.sparkles[j].y, bullet.sparkles[j].size
            r, g, b = unpack(bullet.sparkles[j].color)
            love.graphics.setColor(r, g, b, 1)
            love.graphics.rectangle("fill", x, y, size, size)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end
