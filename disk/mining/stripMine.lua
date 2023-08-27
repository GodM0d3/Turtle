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
    local rightTurns = (targetDirection - facing) % 4
    if rightTurns == 3 then
        turn("left")
    end
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
            return true, slot
        end
    end
    return false, -1
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
    local suc, slot = checkSlotsFor("minecraft:torch")
    if not suc then
        return false
    end
    turtle.select(slot)
    return turtle.place()
end

-- Go to places
local function goToCoordinates(x, z)
    local xDiff = x - xChange
    local zDiff = z - zChange
    if xDiff > 0 then
        turnToDirection(FACING_RIGHT)
        for _ = 1, xDiff do
            if not goHorizontal("forward") then return false end
        end
    elseif xDiff < 0 then
        turnToDirection(FACING_BACK)
        for _ = 1, math.abs(xDiff) do
            if not goHorizontal("forward") then return false end
        end
    end
    
    if zDiff > 0 then
        turnToDirection(FACING_RIGHT)
        for _ = 1, zDiff do
            if not goHorizontal("forward") then return false end
        end
    elseif zDiff < 0 then
        turnToDirection(FACING_LEFT)
        for _ = 1, math.abs(zDiff) do
            if not goHorizontal("forward") then return false end
        end
    end
    return true
end
local function goToHeight(targetHeight)
    local heightDiff = targetHeight - heightChange
    if heightDiff > 0 then
        for _ = 1, heightDiff do
            if not goVertical("up") then return false end
        end
    elseif heightDiff < 0 then
        for _ = 1, math.abs(heightDiff) do
            if not goVertical("down") then return false end
        end
    end
    return true
end
-- Inventory Management
local function EmptyAtHome()
    local cur_x,cur_y,cur_z, cur_facing= xChange, heightChange, zChange, facing
    goToCoordinates(0,0)
    goToHeight(0)
    turnToDirection(FACING_BACK)
    for i=1,INVENTORY_SIZE do
        turtle.select(i)
        if not turtle.drop() then
            return false
        end
    end
    goToHeight(cur_y)
    goToCoordinates(cur_x, cur_z)
    turnToDirection(cur_facing)
    return true
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
    local suc, slot_c = checkSlotsFor("minecraft:chest")
    if not suc then
        return false
    end
    turtle.select(slot_c)
    turtle.place()
    for  pos=1, INVENTORY_SIZE do
        turtle.select(pos)
        local itemDetail = turtle.getItemDetail(pos)
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
-- Mining
local function mineRow(length, up, down)
    for _ = 1, length do
        if countEmptySlots() < 2 then 
            EmptyAtHome()
        end
        while turtle.detect() do
            turtle.dig()
        end
        if not goHorizontal("forward") then
            print("Error: Cant move forward")
        end
        if up then
            while turtle.detectUp() do
                turtle.digUp()
            end
        end
        if down then
            while turtle.detectDown() do
                turtle.digDown()
            end
        end
    end
end
local function mineShaft(height, direction) 
    if height <= 0 then
        print("Error: Cant mine shaft with negative height")
        return false
    end
    for _ = 1, height do
        if direction == "up" then
            while turtle.detectUp() do
                turtle.digUp()
            end
            while not goVertical(direction) do
                turtle.digUp()
            end
        elseif direction == "down" then
            turtle.digDown()
            goVertical(direction)
        end
    end
end
local function mineLayer(xSize, zSize, up, down)
    goToCoordinates(0,0)
    for iteration = 0, zSize - 1 do
        turnToDirection((iteration % 2) * 2)
        mineRow(xSize - 1, up, down)
        if iteration ~= (zSize - 1) then
            turnToDirection(FACING_RIGHT)
            mineRow(1, up, down)
        end
    end
end

-- Main functions
local function cube(xSize, ySize, zSize, yOffset)
    if turtle.getFuelLevel() < (xSize * ySize * zSize) then
        print("Error: Not enough fuel")
        return false
    end
    mineShaft(ySize-yOffset -1, "down")
    goToHeight(0)
    mineShaft(yOffset, "up")
    print("Shaft finished")
    local level = 1
    while level <= ySize do
        goToCoordinates(0,0)
        if level == ySize then
            print("Single level")
            goToHeight(yOffset - level + 1)
            mineLayer(xSize, zSize, false, false)
            level = level + 1
        elseif level + 1 == ySize then
            print("Double level")

            goToHeight(yOffset - level + 1)
            mineLayer(xSize, zSize, false, true)
            level = level + 2
        else
            print("Tripple level")
            goToHeight(yOffset - level)
            mineLayer(xSize, zSize, true, true)
            level = level + 3
        end
    end
    goToHeight(0)
    goToCoordinates(0,0)
    turnToDirection(FACING_FORWARD)
end
turtle.refuel()
cube (3, 7, 2, 0)
--mineShaft(4,"down")