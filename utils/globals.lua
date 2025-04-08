red_vector = { 1, 0 }
green_vector = { math.cos(120 * math.pi / 180), math.sin(120 * math.pi / 180) }
blue_vector = { math.cos(240 * math.pi / 180), math.sin(240 * math.pi / 180) }

function update_color(object, dt, speed)
    object.color_degree = object.color_degree + dt * speed

    local radian = object.color_degree * math.pi / 180
    local cx, cy = unpack({ math.cos(radian), math.sin(radian) })

    local rx, ry = unpack(red_vector)
    object.color[1] = ((cx * rx + cy * ry) + 1) / 2

    local gx, gy = unpack(green_vector)
    object.color[2] = ((cx * gx + cy * gy) + 1) / 2

    local bx, by = unpack(blue_vector)
    object.color[3] = ((cx * bx + cy * by) + 1) / 2
end
