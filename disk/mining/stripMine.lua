-- Global Variables and tables
local xChange, heightChange, zChange, facing = 0, 0, 0, 0
local FACING_FORWARD, FACING_RIGHT, FACING_BACK, FACING_LEFT = 0, 1, 2, 3
local INVENTORY_SIZE = 16
local directions = {
    right = {turtle.turnRight, 1},
    left = {turtle.turnLeft, -1},
    up = {turtle.up, 1},
    down = {turtle.down, -1},
    forward = {turtle.forward, 1},
    back = {turtle.back, -1}
}
local changes = {
    [FACING_FORWARD] = function(dir) xChange = xChange + dir end,
    [FACING_RIGHT] = function(dir) zChange = zChange + dir end,
    [FACING_BACK] = function(dir) xChange = xChange - dir end,
    [FACING_LEFT] = function(dir) zChange = zChange - dir end
}
-- Turn function
local function turn(direction)
    local turn_func, dir = unpack(directions[direction])
    if not turn_func then
        print("Error: turn() called without valid direction")
        return false
    end
    if turn_func() then 
        facing = (facing + dir) % 4 
    end
end
local function turnToDirection(targetDirection)
    while facing ~= targetDirection do
        turn("right")
    end
end
-- Move functions
local function goVertical(direction)
    local go_func, dir = unpack(directions[direction])
    if not go_func then
        print("Error: goVertical() called without valid direction")
        return false
    end
    if go_func() then 
        heightChange = heightChange + dir
        return true
    end
    return false
end
local function goHorizontal(direction)
    local go_func, dir = unpack(directions[direction])
    if not go_func then
        print("Error: goHorizontal() called without direction")
        return false
    end
    if go_func() then
        changes[facing](dir)
        return true
    else
        return false
    end
end
-- Checking inventory
local function checkSlotsFor(check_string)
    for slot = 1, INVENTORY_SIZE do
        local itemDetail = turtle.getItemDetail(slot)
        if itemDetail and itemDetail.name == check_string then
            return slot
        end
    end
    return false
end
local function countEmptySlots()
    local count = 0
    for i = 1, INVENTORY_SIZE do
        if turtle.getItemCount(i) == 0 then
            count = count + 1
        end
    end
    return count
end
-- Place stuff
local function placeTorch()
    local slot = checkSlotsFor("minecraft:torch")
    if slot == -1 then
        return false
    end
    turtle.select(slot)
    return turtle.place()
end
local function placeAndEmpty()
    turn("left")
    goVertical("up")
    while turtle.detect() do
        turtle.dig()
    end
    goVertical("down")
    while turtle.detect() do
        turtle.dig()
    end
    local slot_c = checkSlotsFor("minecraft:chest")
    if slot_c == -1 then
        return false
    end
    turtle.select(slot_c)
    turtle.place()
    for  pos=1, INVENTORY_SIZE do
        turtle.select(pos)
        local itemDetail = turtle.getItemDetail(slot_c)
        if itemDetail and itemDetail.name ~= "minecraft:chest" and itemDetail.name ~= "minecraft:torch" then
            if not turtle.drop() then
                print("Error: Cant drop in placed chest")
                return false
            end
        end
    end
    turn("right")
    return true
end
-- Go to places
local function goToCoordinates(x, z)
    local xDiff = x - xChange
    local zDiff = z - zChange
    if xDiff > 0 then
        turnToDirection(FACING_RIGHT)
        for _ = 1, xDiff do
            goHorizontal("forward")
        end
    elseif xDiff < 0 then
        turnToDirection(FACING_BACK)
        for _ = 1, math.abs(xDiff) do
            goHorizontal("forward")
        end
    end
    
    if zDiff > 0 then
        turnToDirection(FACING_RIGHT)
        for _ = 1, zDiff do
            goHorizontal("forward")
        end
    elseif zDiff < 0 then
        turnToDirection(FACING_LEFT)
        for _ = 1, math.abs(zDiff) do
            goHorizontal("forward")
        end
    end
end
local function goToHeight(targetHeight)
    local heightDiff = targetHeight - heightChange
    if heightDiff > 0 then
        for _ = 1, heightDiff do
            goVertical("up")
        end
    elseif heightDiff < 0 then
        for _ = 1, math.abs(heightDiff) do
            goVertical("down")
        end
    end
end
-- Others
local function EmptyAtHome()
    turnToDirection(FACING_BACK)
    for i=1,INVENTORY_SIZE do
        turtle.select(i)
        if not turtle.drop() then
            return false
        end
    end
    return true
end

-- Main functions
local function cube (x, height, z, upOffset, homeFunc)
    local init, turnR 
    for i =1, upOffset do
        while not goVertical("up") do
            turtle.digUp()
        end
    end
    local u = 2
    local anotherLayer = false
    repeat
        anotherLayer = false
        init = true
        turnR = true
        for i = 1, z do
            if not init then
                if turnR then
                    turn("right")
                else
                    turn("left")
                end
                turtle.dig()
                turtle.digDown()
                goHorizontal("forward")
                if turnR then
                    turn("right")
                else
                    turn("left")
                end
                turtle.dig()
                turtle.digDown()
                turnR = not turnR
            end
            init = false
            -- go down
            for j = 2, x do
                turtle.dig()
                turtle.digDown()
                goHorizontal("forward")
            end
        end
        turtle.digDown()
        goHome(false)
        if not (homeFunc == nil) then
            goHome(true)
            io.write("[HomeFunc] ")
            if not homeFunc() then
                return false
            end
            goResumeHeight()
        end
        if u < height then
            anotherLayer = true
            turtle.digDown()
            goVertical("down")
            u = u + 1
        end
        if u < height then
            turtle.digDown()
            goVertical("down")
            u = u + 1
        end
    until not anotherLayer
    goHome(false)
end

cube(5, 5, 6, 1, nil)