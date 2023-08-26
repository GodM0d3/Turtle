local xChange = 0
local heightChange = 0
local zChange = 0
local facing = 0
local bridge = false

local function turnRight()
    if turtle.turnRight() then
        facing = facing + 1
        facing = facing % 4
        return true
    else
        return false
    end
end
local function turnLeft()
    if turtle.turnLeft() then 
        facing = facing - 1
        facing = facing % 4
        return true
    else
        return false
    end
end
local function goDown()
    if turtle.down() then
        heightChange = heightChange - 1
        return true
    else
        return false
    end
end
local function goUp()
    if turtle.up() then 
        heightChange = heightChange + 1
        return true
    else
        return false
    end
end
local function goForward()
    if turtle.forward() then
        if facing == 0 then
            xChange = xChange + 1
        elseif facing == 1 then
            zChange = zChange + 1
        elseif facing == 2 then
            xChange = xChange - 1
        elseif facing == 3 then
            zChange = zChange - 1
        end
        return true
    else
        return false
    end
end
local function goBack()
    if turtle.back() then
        if facing == 0 then
            xChange = xChange - 1
        elseif facing == 1 then
            zChange = zChange - 1
        elseif facing == 2 then
            xChange = xChange + 1
        elseif facing == 3 then
            zChange = zChange + 1
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

local function emptyInventory()
    turnLeft()
    goUp()
    while turtle.detect() do
        turtle.dig()
    end
    goDown()
    while turtle.detect() do
        turtle.dig()
    end
    slot = checkSlotsFor("minecraft:chest")
    if slot == -1 then
        return false
    end
    turtle.select(slot)
    turtle.place()
    for i =1, 16 do
        turtle.select(i)
        local itemDetail = turtle.getItemDetail(slot)
        if itemDetail and itemDetail.name ~= "minecraft:chest" and itemDetail.name ~= "minecraft:torch" then
            turtle.drop()
        end
    end
    turnRight()
    return true
end
local function goHome(changeHeight)
    while facing ~= 2 do
        turnRight()
    end
    while xChange > 0 do
        goForward()
    end
    turnRight()
    while zChange > 0 do
        goForward()
    end
    turnRight()
    if changeHeight then
        while heightChange < 0 do
            goUp()
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
local function deposit(all)
    if not all then
        return turtle.drop()
    end
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end
end
local function cube (x, height, z, upOffset)
    local init, turnR 
    for i =1, upOffset do
        while not goUp() do
            turtle.digUp()
        end
    end
    local u = 2
    repeat
        init = true
        turnR = true
        for i = 1, z do
            if not init then
                if turnR then
                    turnRight()
                else
                    turnLeft()
                end
                turtle.dig()
                turtle.digDown()
                goForward()
                if turnR then
                    turnRight()
                else
                    turnLeft()
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
                goForward()
            end
        end
        turtle.digDown()
        goHome(false)
        if u < height then
            turtle.digDown()
            goDown()
            u = u + 1
        end
        if u < height then
            turtle.digDown()
            goDown()
            u = u + 1
        end
    until u >= height
    goHome(false)
end

cube(5, 3, 6, 1)