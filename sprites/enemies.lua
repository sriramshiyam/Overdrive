enemies = {}

function enemies:load()
    self.texture = love.graphics.newImage("res/image/enemy.png")
    self.list = {}
    table.insert(self.list,
        {
            position = { x = 300, y = 300 },
            anim = {
                frame_width = self.texture:getWidth() / 3,
                frame_height = self.texture:getHeight(),
                frame_quad = love.graphics.newQuad(0, 0, self.texture:getWidth() / 3, self.texture:getHeight(),
                    self.texture:getWidth(), self.texture:getHeight()),
                frame_time = 0.1,
                frame_number = 0,
                frame_count = 3
            }
        })
end

function enemies:update(dt)
    for i = 1, #self.list do
        self:update_animation(self.list[i].anim, dt)
    end
end

function enemies:update_animation(anim, dt)
    anim.frame_time = anim.frame_time - dt
    if anim.frame_time < 0 then
        anim.frame_number = anim.frame_number + 1
        if anim.frame_number == anim.frame_count then
            anim.frame_number = 0
        end
        anim.frame_time = 0.1
        anim.frame_quad:setViewport(anim.frame_width * anim.frame_number, 0, anim.frame_width, anim.frame_height)
    end
end

function enemies:draw()
    for i = 1, #self.list do
        love.graphics.draw(self.texture, self.list[i].anim.frame_quad, self.list[i].position.x, self.list[i].position.y)
    end
end
