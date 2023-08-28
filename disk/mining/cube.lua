--wget https://raw.githubusercontent.com/GodM0d3/Turtle/main/disk/mining/cube.lua cube.lua
-- Global Variables and tables
local own_pos = {x = 0, y = 0, z = 0, facing = 0}
local chest_pos = {x = 0, y = 0, z = 0}
local return_pos = {x = 0, y = 0, z = 0, facing = 0}
local FACING_FORWARD, FACING_RIGHT, FACING_BACK, FACING_LEFT = 0, 1, 2, 3
local INVENTORY_SIZE = 16
local use_Chests = true
local directions = {
    right = {turtle.turnRight, 1},
    left = {turtle.turnLeft, -1},
    up = {turtle.up, 1},
    down = {turtle.down, -1},
    forward = {turtle.forward, 1},
    back = {turtle.back, -1}
}
local changes = {
    [FACING_FORWARD] = function(dir) own_pos.x = own_pos.x + dir end,
    [FACING_RIGHT] = function(dir) own_pos.z = own_pos.z + dir end,
    [FACING_BACK] = function(dir) own_pos.x = own_pos.x - dir end,
    [FACING_LEFT] = function(dir) own_pos.z = own_pos.z - dir end
}
-- Turn function
local function turn(direction)
    local turn_func, dir = unpack(directions[direction])
    if not turn_func then
        print("Error: turn() called without valid direction")
        return false
    end
    if turn_func() then 
        own_pos.facing = (own_pos.facing + dir) % 4 
    end
end
local function turnToDirection(targetDirection)
    local rightTurns = (targetDirection - own_pos.facing) % 4
    if rightTurns == 3 then
        turn("left")
    end
    while own_pos.facing ~= targetDirection do
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
        own_pos.y = own_pos.y + dir
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
        changes[own_pos.facing](dir)
        return true
    end
    return false
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
-- Go to places
local function goToCoordinates(x,y, z)
    local xDiff, yDiff, zDiff = x - own_pos.x, y - own_pos.y, z - own_pos.z
    if xDiff > 0 then
        turnToDirection(FACING_FORWARD)
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
    if yDiff > 0 then
        for _ = 1, zDiff do
            if not goVertical("up") then return false end
        end
    elseif yDiff < 0 then
        for _ = 1, math.abs(zDiff) do
            if not goHorizontal("down") then return false end
        end
    end
    return true
end
-- Inventory Management
-- First return is if it was successful, second is if it was able to return to original location
local function emptyAt(x_loc, y_loc, z_loc)
    return_pos.x, return_pos.y, return_pos.z, return_pos.facing = own_pos.x, own_pos.y, own_pos.z, own_pos.facing
    if not goToCoordinates(x_loc,y_loc,z_loc) then
        print("Error: emptyAt: Cant go to location")
        local tmp = goToCoordinates(return_pos.x,return_pos.y, return_pos.z)
        return false,tmp
    end
    turnToDirection(FACING_BACK)
    if own_pos.x == x_loc and own_pos.z == z_loc and own_pos.y == y_loc then
        for i=1,INVENTORY_SIZE do
            turtle.select(i)
            if not turtle.drop() then
                print("Error: emptyAt: Cant drop items at location")
                local tmp = goToCoordinates(return_pos.x,return_pos.y, return_pos.z)
                return false,tmp
            end
        end
    end
    if not goToCoordinates(own_pos.x,return_pos.y, own_pos.z) then
        print("Error: emptyAt: Cant return to height")
        return false,false
    end 
    if not goToCoordinates(return_pos.x,return_pos.y, return_pos.z) then 
        print("Error: emptyAt: Cant return to original location")
        return false,false
    end
    turnToDirection(return_pos.facing)
    if own_pos.x == return_pos.x and own_pos.z == return_pos.z and own_pos.y == return_pos.y and own_pos.facing == return_pos.facing then
        return true,true
    end
    print("Error: emptyAt: Reached end of function without returning")
    return false,false
end
-- Mining
local function mineRow(length, up, down)
    for _ = 1, length do
        if use_Chests and countEmptySlots() < 2 then 
            local suc, ret = emptyAt(0,0,0)
            if not suc then
                print("mineRow: Error when empting inventory")
                if not ret then
                    print("Error: Didnt return to original location. Aborting")
                    return false
                end
                print("Returned to original location, continuing")
            end
        end
        while turtle.detect() do
            turtle.dig()
        end
        if not goHorizontal("forward") then
            print("Error: mineRow: Cant move forward")
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
    if height < 0 then
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
    return true
end
local function mineLayer(xSize, zSize, up, down)
    if turtle.getFuelLevel() < ((xSize * zSize) + zSize) then
        print("Error: Not enough fuel")
        return false
    end
    goToCoordinates(0,own_pos.y,0)
    for iteration = 0, zSize - 1 do
        turnToDirection((iteration % 2) * 2)
        if not mineRow(xSize - 1, up, down) then
            print("Error: Cant mine row")
            return false
        end
        if iteration ~= (zSize - 1) then
            turnToDirection(FACING_RIGHT)
            if not mineRow(1, up, down) then
                print("Error: Cant mine row")
                return false
            end
        end
    end
    return true
end
-- Main functions
local function cube(xSize, ySize, zSize)
    mineShaft(ySize -1, "down")
    goToCoordinates(own_pos.x,0,own_pos.z)
    print("Shaft finished")
    local level = 0
    while level <= ySize do
        goToCoordinates(0,own_pos.y,0)
        if level == -ySize then
            print("Single level")
            goToCoordinates(own_pos.x,level,own_pos.z)
            mineLayer(xSize, zSize, false, false)
            level = level - 1
        elseif level + 1 == -ySize then
            print("Double level")
            goToCoordinates(own_pos.x,level,own_pos.z)
            mineLayer(xSize, zSize, false, true)
            level = level - 2
        else
            print("Tripple level")
            goToCoordinates(own_pos.x,level - 1,own_pos.z)
            mineLayer(xSize, zSize, true, true)
            level = level - 3
        end
    end
    goToCoordinates(own_pos.x,0,own_pos.y)
    goToCoordinates(0,own_pos.y,0)
    turnToDirection(FACING_FORWARD)
end

turtle.refuel()
cube (3, 7, 2)
