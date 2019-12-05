intCodes = File.read("input.txt").split(',').map {|s| s.to_i}

halt = false
ip = 0

def compute(intCodes, ip, halt)
    instruction = intCodes[ip]
    opCode = get_op_code(instruction)
    if opCode == 1
        intCodes[intCodes[ip+3]] = get_value(intCodes, ip, instruction, 1) + get_value(intCodes, ip, instruction, 2)
    elsif opCode == 2
        intCodes[intCodes[ip+3]] = get_value(intCodes, ip, instruction, 1) * get_value(intCodes, ip, instruction, 2)
    elsif opCode == 3
        intCodes[intCodes[ip+1]] = gets().to_i
    elsif opCode == 4
        puts get_value(intCodes, ip, instruction, 1)
    elsif opCode == 5
        if get_value(intCodes, ip, instruction, 1) != 0
            ip = get_value(intCodes, ip, instruction, 2)
            return [ip, halt]
        end
    elsif opCode == 6
        if get_value(intCodes, ip, instruction, 1) == 0
            ip = get_value(intCodes, ip, instruction, 2)
            return [ip, halt]
        end    
    elsif opCode == 7
        if get_value(intCodes, ip, instruction, 1) < get_value(intCodes, ip, instruction, 2)
            intCodes[intCodes[ip+3]] = 1
        else
            intCodes[intCodes[ip+3]] = 0
        end
    elsif opCode == 8
        if get_value(intCodes, ip, instruction, 1) == get_value(intCodes, ip, instruction, 2)
            intCodes[intCodes[ip+3]] = 1
        else
            intCodes[intCodes[ip+3]] = 0
        end
    elsif opCode == 99
        halt = true
    else
        raise opCode.to_s + 'errorCOMP'
    end

    instruction_length = get_instruction_length(opCode)
    return [ip + instruction_length, halt]
end

def get_instruction_length(code) 
    if code == 1 || code == 2 
        return 4
    elsif code == 3 || code == 4
        return 2
    elsif code == 5 || code == 6
        return 3
    elsif code == 7 || code == 8
        return 4
    elsif code == 99
        return 1
    else
        raise code.to_s + 'errorIL'
    end
end

def get_op_code(intCode) 
    if intCode < 100
        return intCode
    else
        return intCode.to_s[-2,2].to_i
    end
end

def get_mode(instruction, parameter)
    if instruction.to_s.length < 2 + parameter
        return 0
    end

    return instruction.to_s[-(2+parameter)].to_i
end

def get_value(intCodes, ip, instruction, parameter)
    if get_mode(instruction, parameter) == 1
        return intCodes[ip + parameter]
    else
        return intCodes[intCodes[ip + parameter]]
    end
end

while !halt do
    ip, halt = compute(intCodes, ip, halt)
end