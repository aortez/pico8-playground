pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- waves demo
-- by zep

r=64
x=78
y=100

boat = {x = 60, y = 110}

water_to_add = 20000

grid = {}

function newPoint()
    return {color = 0, density = 0, x_f = 0.0, y_f = 0.0}
end

function _init()

    for y = 1, 128 do
        grid[y] = {}
        for x = 1, 128 do
            grid[y][x] = newPoint()
        end
    end

    for y = 100, 128 do
        for x = 1, 30 do
            grid[y][x].color = 3
        end
    end

    for y = 115, 128 do
        for x = 55, 70 do
            grid[y][x].color = 3
        end
    end

    for y = 100, 128 do
        grid[y][55].color = 3
        grid[y][70].color = 3
    end

    for y = 110, 128 do
        for x = 80, 100 do
            grid[y][x].color = 3
        end
    end
end

function _draw()
    cls()

    for y = 2, 126 do
        for x = 2, 126 do
            -- Water
            if (grid[y][x].color == 1) then
                -- Only draw water if it is thick enough.
                if (grid[y][x].density > 0.1) then
                    pset(x, y, 1)
                else

                end

                if (grid[y][x].density > 0.5) then
                    pset(x, y, 1)
                end

            -- Other stuff
            else
                pset(x, y , grid[y][x].color)
            end

        end
    end

    pset(x, y , 2)

    pset(boat.x, boat.y, 4)
end

function _update60()
    if (btn(0)) x -= 1
    if (btn(1)) x += 1
    if (btn(2)) y -= 1
    if (btn(3)) y += 1

    if (x < 2) x = 2
    if (x > 126) x = 126
    if (y < 2) y = 2
    if (y > 126) y = 126

    if (water_to_add > 0) then
        for x = 2, 20 do
            if (water_to_add > 0) then
                grid[80][x].color = 1
                grid[80][x].density = 1
                water_to_add -= 1
            end
        end

        if (water_to_add > 0) then
            grid[110][67].color = 1
            grid[110][67].density = 1
            water_to_add -= 1
        end

        if (water_to_add > 0) then
            grid[100][86].color = 1
            grid[100][86].density = 1
            water_to_add -= 1
        end

        if (water_to_add > 0) then
            grid[100][85].color = 1
            grid[100][85].density = 1
            water_to_add -= 1
        end
    end

    -- On button down, add drop of water at cursor.
    if (btn(4)) then
        grid[y][x].color = 1
        grid[y][x].density = 1
    end

    -- Is the boat under water?
    if (grid[boat.y][boat.x].density > 0.1) then
        -- Push on the water pixel.
        g.y_f += 1

        -- Push on the boat.
        -- if (boat.y < 120) boat.y += 0.1
    end

    -- Apply forces to the water drops.
    -- Well, ok for now just move them directly.
    for y = 3, 125 do
        for x = 2, 125 do
            -- Are we looking at water?
            g = grid[y][x]
            if (g.color == 1) then

                -- Apply downforce.
                g.y_f += 0.1

                -- if (g.y_f < 1) goto continue

                below = grid[y + 1][x]
                left = grid[y][x - 1]
                right = grid[y][x + 1]
                d = 0.2

                -- Is the square below empty?
                if ((below.color == 1 or below.color == 0) and below.density < g.density) then
                    -- Transfer water down.
                    delta = g.y_f * (g.density - below.density)
                    below.density += delta
                    if (below.density > 0) below.color = 1

                    g.density -= delta
                    if (g.density <= 0) g.color = 0

                    g.y_f -= delta
                end

                if (g.density <= 0 or g.y_f <= 0) goto continue

                -- What about cases where density is > 1 ? Can we transfer force?
                right_open = (right.color == 1 or right.color == 0) and right.density < 1 + d
                left_open = (left.color == 1 or left.color == 0) and left.density < 1 + d

                do_left = false
                do_right = false
                if (left_open and not right_open) then
                    do_left = true
                elseif (right_open and not left_open) then
                    do_right = true
                elseif (right_open and left_open) then
                    do_left = rnd() > 0.5
                    do_right = not do_left
                end

                if (do_right) then
                    half = (right.density + g.density) / 2
                    right.density = half
                    g.density = half
                    -- right.density += d
                    if (right.density > 0) right.color = 1

                    -- g.density -= d
                    if (g.density <= 0) g.color = 0

                    g.y_f = 0
                end

                if (do_left) then
                    half = (left.density + g.density) / 2
                    left.density = half
                    g.density = half
                    if (left.density > 0) left.color = 1

                    if (g.density <= 0) g.color = 0

                    g.y_f = 0
                end

                if (g.density <= 0 or g.y_f <= 0) goto continue

                above = grid[y - 1][x]
                -- Is the square above empty?
                if ((above.color == 1 or above.color == 0) and above.density < g.density) then
                    g.y_f *= 0.5
                    -- Transfer water up.
                    above.density += g.y_f
                    if (above.density > 0) above.color = 1

                    g.density -= g.y_f
                    if (g.density <= 0) g.color = 0

                    g.y_f = 0
                end

            end

            ::continue::

        end
    end

end
