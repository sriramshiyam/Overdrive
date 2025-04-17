sound = {}

function sound:load()
    self.laser = love.audio.newSource("res/sound/laser.wav", "static")
    self.destroyed = love.audio.newSource("res/sound/destroyed.wav", "static")
end

function sound:play_destroyed()
    self.destroyed:clone():play()
end