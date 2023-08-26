local xChange, heightChange, zChange, facing, resumeHeight = 0, 0, 0, 0, 0
local bridge = false

local FACING_FORWARD = 0
local FACING_RIGHT = 1
local FACING_BACK = 2
local FACING_LEFT = 3

local function turn(direction)
    if direction == "right" then
        if turtle.turnRight() then facing = (facing + 1) % 4 end
    elseif direction == "left" then
        if turtle.turnLeft() then facing = (facing - 1) % 4 end
    end
end

local function goVertical(direction)
    if direction == "up" then
        if turtle.up() then 
            heightChange = heightChange + 1
            return true
        end
    elseif direction == "down" then
        if turtle.down() then 
            heightChange = heightChange - 1
            return true
        end
    end
    return false
end

local function goHorizontal(direction)
    local suc, dir
    if direction == "forward" then
        dir = 1
        suc = turtle.forward()
    elseif direction == "back" then
        dir = -1
        suc = turtle.back()
    else
        print("Error: goHorizontal() called without direction")
        return false
    end
    if suc then
        if facing == FACING_FORWARD then
            xChange = xChange + dir
        elseif facing == FACING_RIGHT then
            zChange = zChange + dir
        elseif facing == FACING_BACK then
            xChange = xChange - dir
        elseif facing == FACING_LEFT then
            zChange = zChange - dir
        end
        return true
    else
        return false
    end
end
local function checkSlotsFor(check_string)
    for slot = 1, 16 do
        local itemDetail = turtle.getItemDetail(slot)
        if itemDetail and itemDetail.name == check_string then
            return slot
        end
    end
    return false
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
    for  pos=1, 16 do
        turtle.select(pos)
        local itemDetail = turtle.getItemDetail(slot_c)
        if itemDetail and itemDetail.name ~= "minecraft:chest" and itemDetail.name ~= "minecraft:torch" then
            turtle.drop()
        end
    end
    turn("right")
    return true
end
local function goHome(changeHeight)
    while xChange ~= 0 and facing ~= FACING_BACK do
        turn("right")
    end
    while xChange > 0 do
        goHorizontal("forward")
    end
    while zChange ~= 0 and facing ~= FACING_LEFT do
        turn("right")
    end
    while zChange > 0 do
        goHorizontal("forward")
    end
    turn("right")
    if changeHeight then
        while heightChange ~= 0 do
            if heightChange > 0 then
                goVertical("down")
                resumeHeight=resumeHeight + 1
            else
                goVertical("up")
                resumeHeight=resumeHeight - 1
            end
        end
    end
end
local function goResumeHeight()
    while resumeHeight ~= 0 do
        if resumeHeight < 0 then
            goVertical("down")
            resumeHeight=resumeHeight + 1
        else
            goVertical("up")
            resumeHeight=resumeHeight - 1
        end
    end
end
local function placeTorch()
    local slot = checkSlotsFor("minecraft:torch")
    if slot == -1 then
        return false
    end
    turtle.select(slot)
    return turtle.place()
end
local function countEmptySlots()
    local count = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            count = count + 1
        end
    end
    return count
end
local function EmptyAtHome()
    turn("right")
    turn("right")
    for i=1,16 do
        turtle.select(i)
        if not turtle.drop() then
            turn("right")
            turn("right")
            return false
        end
    end
    turn("right")
    turn("right")
    return true
end
local function deposit()
    if countEmptySlots() < 3 then
        return EmptyAtHome()
    end
end
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

cube(5, 5, 6, 1, deposit)
goHome(true)