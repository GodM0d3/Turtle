local xChange = 0
local heightChange = 0
local zChange = 0
local facing = 0
local bridge = false

local function turnRight()
    if turtle.turnRight() then
        originalFacing = originalFacing + 1
        originalFacing = originalFacing % 4
        return true
    else
        return false
    end
end
local function turnLeft()
    if turtle.turnLeft() then 
        originalFacing = originalFacing - 1
        originalFacing = originalFacing % 4
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

local function strip_mine (length)
    local counter = 0
    while turtle.detect() do
        turtle.dig()
    end
    
end

strip_mine(100)