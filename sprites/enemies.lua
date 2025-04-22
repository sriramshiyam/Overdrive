enemies = {}

function enemies:load()
    self.spawn_timer = 2
    self.texture = love.graphics.newImage("res/image/enemy.png")
    self.spawn_texture = love.graphics.newImage("res/image/spawn.png")
    self.list = {}
    self.spawn_anim = {}
    self.spawn_timer = 2.0
    self.wave = 1
    self.wave_timer = 30
end

function enemies:update(dt)
    if self.wave_timer > 0 then
        self.wave_timer = self.wave_timer - dt
    else
        if not player.frenzy_mode then
            player:init_frenzy_mode()
        end
        if music.game:getPitch() == 1.0 then
            music.game:setPitch(1.2)
            sound.destroyed:setVolume(0.5)
        end
    end

    self.spawn_timer = self.spawn_timer - dt
    if self.spawn_timer < 0 and not player.crosshairs.loading then
        self.spawn_timer = (self.wave_timer > 0 and 2.0) or 1.0
        self:spawn_enemies()
    end

    if #self.list > 0 then
        if not player.crosshairs.loading then
            self:move_towards_player(dt)
        end

        for i = 1, #self.list do
            local enemy = self.list[i]
            if enemy.is_spawned and not enemy.is_dead then
                self:update_animation(enemy.anim, dt)
            end
            if enemy.is_dead then
                enemy.scale = enemy.scale - dt * 2.5
                enemy.rotation = enemy.rotation + dt * 1000
                enemy.position.x = enemy.position.x + enemy.dead_direction.x * 300 * dt
                enemy.position.y = enemy.position.y + enemy.dead_direction.y * 300 * dt
            end
        end

        if not self.spawn_anim.anim_finished then
            local spawn_anim = self.spawn_anim
            self:update_animation(spawn_anim, dt)
            if spawn_anim.frame_number < 3 then
                spawn_anim.scale = spawn_anim.scale - 4 * dt
            else
                spawn_anim.scale = spawn_anim.scale + 8 * dt
            end
        end
    end

    for i = #self.list, 1, -1 do
        if self.list[i].scale < 0 then
            table.remove(self.list, i)
        end
    end
end

function enemies:move_towards_player(dt)
    for i = 1, #self.list do
        local enemy = self.list[i]

        if enemy.is_spawned and not enemy.is_dead then
            local direction = { x = player.origin.x - enemy.origin.x, y = player.origin.y - enemy.origin.y }
            local length = vector_length(direction.x, direction.y)

            direction.x = direction.x / length
            direction.y = direction.y / length

            enemy.position.x = enemy.position.x + direction.x * enemy.speed * dt
            enemy.position.y = enemy.position.y + direction.y * enemy.speed * dt
            enemy.rect.x = enemy.position.x - enemy.anim.width / 2
            enemy.rect.y = enemy.position.y - enemy.anim.height / 2
            enemy.origin.x = enemy.position.x + enemy.anim.width / 2
            enemy.origin.y = enemy.position.y + enemy.anim.height / 2
        end
    end
end

function enemies:update_animation(anim, dt)
    anim.timer = anim.timer - dt
    if anim.timer < 0 then
        anim.frame_number = anim.frame_number + 1
        if anim.frame_number == anim.frame_count then
            anim.frame_number = 0
            if anim.is_spawn_anim then
                anim.anim_finished = true
                for i = 1, #self.list do
                    if not self.list[i].is_spawned then
                        self.list[i].is_spawned = true
                    end
                end
            end
        end
        anim.timer = anim.time
        anim.quad:setViewport(anim.width * anim.frame_number, 0, anim.width, anim.height)
    end
end

function enemies:spawn_enemies()
    local no_of_enemies = (self.wave_timer > 0 and love.math.random(2, 4)) or love.math.random(8, 10)
    for _ = 1, no_of_enemies do
        local x, y = love.math.random(100, canvas_width - 100), love.math.random(100, canvas_height - 100)

        while vector_length(player.position.x - x, player.position.y - y) < 300 do
            x, y = love.math.random(100, canvas_width - 100), love.math.random(100, canvas_height - 100)
        end

        table.insert(self.list,
            {
                marked_no = 0,
                is_dead = false,
                is_spawned = false,
                position = { x = x, y = y },
                rotation = 0,
                scale = 1,
                rect = {
                    x = 0,
                    y = 0,
                    width = self.texture:getWidth() / 3,
                    height = self.texture:getHeight()
                },
                origin = { x = x + self.texture:getWidth() / 3 / 2, y = y + self.texture:getHeight() / 2 },
                speed = 300,
                anim = {
                    width = self.texture:getWidth() / 3,
                    height = self.texture:getHeight(),
                    quad = love.graphics.newQuad(0, 0, self.texture:getWidth() / 3, self.texture:getHeight(),
                        self.texture:getWidth(), self.texture:getHeight()),
                    time = 0.075,
                    frame_number = 0,
                    frame_count = 3,
                    timer = 0.075
                }
            })
    end
    self:load_spawn_anim()
end

function enemies:load_spawn_anim()
    self.spawn_anim = {
        is_spawn_anim = true,
        width = self.spawn_texture:getWidth() / 4,
        height = self.spawn_texture:getHeight(),
        quad = love.graphics.newQuad(0, 0, self.spawn_texture:getWidth() / 4,
            self.spawn_texture:getHeight(), self.spawn_texture:getWidth(), self.spawn_texture:getHeight()),
        time = 0.175,
        frame_number = 0,
        frame_count = 4,
        timer = 0.175,
        scale = 2.5,
        anim_finished = false
    }
end

function enemies:draw()
    for i = 1, #self.list do
        if self.list[i].is_spawned then
            local quad, x, y = self.list[i].anim.quad, self.list[i].position.x, self.list[i].position.y
            local rotation, scale = self.list[i].rotation, self.list[i].scale
            local width, height = self.list[i].anim.width, self.list[i].anim.height
            love.graphics.draw(self.texture, quad, x, y, rotation * math.pi / 180, scale, scale, width / 2, height / 2)
        else
            local spawn_anim = self.spawn_anim
            local quad, x, y = spawn_anim.quad, self.list[i].origin.x, self.list[i].origin.y
            local scale, ox, oy = spawn_anim.scale, spawn_anim.width / 2, spawn_anim.height / 2
            love.graphics.draw(self.spawn_texture, quad, x, y, 0, scale, scale, ox, oy)
        end
    end
end
