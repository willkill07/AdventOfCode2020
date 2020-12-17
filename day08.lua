local instructions = {}

for line in io.lines(arg[1]) do
    local ins, arg = line:match("^(%w+) ([%-%+]+[0-9]+)$")
    table.insert(instructions, {ins, arg})
end

function toggle(instruction)
    if instruction[1] == "jmp" then
        instruction[1] = "nop"
    elseif instruction[1] == "nop" then
        instruction[1] = "jmp"
    end
end

function simulate(instructions, backtrace, pc, acc)
    acc = acc or 0
    pc = pc or 1
    local visits = {}

    local machine = {
        ["nop"] = function(arg) pc = pc + 1 end,
        ["acc"] = function(arg) acc = acc + arg    pc = pc + 1 end,
        ["jmp"] = function(arg) pc = pc + arg end
    }

    while true do
        table.insert(backtrace, {pc, acc})
        
        if visits[pc] ~= nil or (pc == #instructions) then
            return acc
        end
        visits[pc] = true
        
        local ins = instructions[pc][1]
        local arg = instructions[pc][2]
        
        machine[ins](arg)
    end
end

function part1(instructions, bc)
    return simulate(instructions, bc)
end

function part2(instructions, bc)
    for i, b in ipairs(bc) do
        if instructions[b[1]][1] ~= "acc" then
            toggle(instructions[b[1]])
            local new_bc = {}
            local acc = simulate(instructions, new_bc, b[1], b[2])
            if new_bc[#new_bc][1] == #instructions then
                return acc
            end
            toggle(instructions[b[1]])
        end
    end
end

local bc = {}

local answer1 = part1(instructions, bc)
local answer2 = part2(instructions, bc)

print(answer1)
print(answer2)