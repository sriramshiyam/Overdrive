enemies = {}

function enemies:load()
    self.spawn_timer = 2
    self.texture = love.graphics.newImage("res/image/enemy.png")
    self.spawn_texture = love.graphics.newImage("res/image/spawn.png")
    self.list = {}
    table.insert(self.list,
        {
            is_spawned = false,
            position = { x = 300, y = 300 },
            origin = { x = 300 + self.texture:getWidth() / 3 / 2, y = 300 + self.texture:getHeight() / 2 },
            anim = {
                width = self.texture:getWidth() / 3,
                height = self.texture:getHeight(),
                quad = love.graphics.newQuad(0, 0, self.texture:getWidth() / 3, self.texture:getHeight(),
                    self.texture:getWidth(), self.texture:getHeight()),
                time = 0.075,
                frame_number = 0,
                frame_count = 3,
                timer = 0.075
            },
            spawn_anim = {
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
        })
end

function enemies:update(dt)
    for i = 1, #self.list do
        if self.list[i].is_spawned then
            self:update_animation(self.list[i].anim, dt)
        else
            local spawn_anim = self.list[i].spawn_anim
            self:update_animation(spawn_anim, dt)
            if spawn_anim.frame_number < 3 then
                spawn_anim.scale = spawn_anim.scale - 4 * dt
            else
                spawn_anim.scale = spawn_anim.scale + 8 * dt
            end
            if spawn_anim.anim_finished then
                self.list[i].is_spawned = true
            end
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
            end
        end
        anim.timer = anim.time
        anim.quad:setViewport(anim.width * anim.frame_number, 0, anim.width, anim.height)
    end
end

function enemies:draw()
    for i = 1, #self.list do
        if self.list[i].is_spawned then
            local quad, x, y = self.list[i].anim.quad, self.list[i].position.x, self.list[i].position.y
            love.graphics.draw(self.texture, quad, x, y)
        else
            local spawn_anim = self.list[i].spawn_anim
            local quad, x, y = spawn_anim.quad, self.list[i].origin.x, self.list[i].origin.y
            local scale, ox, oy = spawn_anim.scale, spawn_anim.width / 2, spawn_anim.height / 2
            love.graphics.draw(self.spawn_texture, quad, x, y, 0, scale, scale, ox, oy)
        end
    end
end
