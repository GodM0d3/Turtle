-- Get the arguments
local amount_ = tonumber(arg[1]) or 5 -- Default to 5 if no argument is given
local length_ = tonumber(arg[2]) or 32 -- Default to 32 if no argument is given

-- MAKE YOUR ADJUSTMENTS HERE
branch = {amount = amount_, 	-- the amount of "branch-pairs"
	  length = length_,	-- the length of each branch
	  space  = 5}	-- the space between each branch-pair
slot = {fuel  = 1,	-- the slotnumber for fuel
	torch = 2,	-- the slotnumber for torches
	fill  = 3}	-- the slotnumber for filling material
other = {torch = true,  -- place torches? (true=yes/false=no)
         close = true}  -- close the branches? (true=yes/false=no)
-- END OF ADJUSTMENTS

-- rest of the script...
function main()
 for i=1, branch.amount, 1 do
  refuel(1+(branch.space+branch.length*4)/96)
  forward(1)
  turnAround()
  torch()
  turnAround()
  forward(branch.space)
  turnLeft()
  forward(branch.length)
  back(branch.length)
  turnAround()
  forward(branch.length)
  back(branch.length)
  turnLeft()
 end
end

function forward(length)
 for i=1, length, 1 do
  while turtle.detect() or turtle.detectUp() do
   turtle.dig()
   turtle.digUp()
   sleep(0.5)
  end
  if turtle.detectDown() == false then
   turtle.select(slot.fill)
   turtle.placeDown()
  end
  turtle.forward()
 end
end

-- TurtleAPI

function refuel(amount)
 if turtle.getFuelLevel() == "unlimited" then return end
 if turtle.getFuelLevel() < 96*amount then
  turtle.select(slot.fuel)
  turtle.refuel(amount)
 end
end

function back(length)
 for i=1, length, 1 do
  if i==9 then torch() end --places a torch after the first 8 blocks and
  if (i-8)%16==0 and i>9 then torch() end --then another every 16 blocks
  turtle.back()
  if i==length-1 and other.close then --closes the branch 
   turtle.select(slot.fill)
   turtle.placeUp()
  end
 end
end

function turnLeft()
 turtle.turnLeft()
end

function turnRight()
 turtle.turnRight()
end

function turnAround()
 turtle.turnRight()
 turtle.turnRight()
end

function torch()
 if other.torch then
  turtle.select(slot.torch)
  turtle.place()
 end
end

main()