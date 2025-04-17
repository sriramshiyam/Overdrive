music = {}

function music:load()
    self.game = love.audio.newSource("res/music/game.mp3", "stream")
    self.game:setLooping(true)
    self.game:play()
end
