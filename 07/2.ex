defmodule IntComputer do
  def get_op_code(intCode) do
    rem(intCode, 100)
  end

  def get_mode(instruction, parameter) do
    if :math.floor(:math.log10(instruction)) + 1 < 2 + parameter do
      0
    else
      Integer.digits(instruction) |> Enum.at(-(2 + parameter))
    end
  end

  def get_value(intCodes, ip, instruction, parameter) do
    cond do
      get_mode(instruction, parameter) == 1 -> intCodes[ip + parameter]
      true -> intCodes[intCodes[ip + parameter]]
    end
  end

  def add(intCodes, ip) do
    instruction = intCodes[ip]
    %{intCodes | intCodes[ip + 3] =>
    get_value(intCodes, ip, instruction, 1) + get_value(intCodes, ip, instruction, 2)}
  end

  def mul(intCodes, ip) do
    instruction = intCodes[ip]
    %{intCodes | intCodes[ip + 3] =>
                get_value(intCodes, ip, instruction, 1) * get_value(intCodes, ip, instruction, 2)}
  end

  def compute(program_state) do
    intCodes = program_state[:intCodes]
    ip = program_state[:ip]
    input = program_state[:input]
    output = program_state[:output]
    instruction = intCodes[ip]
    opCode = get_op_code(instruction)
    instruction_length = get_instruction_length(opCode)

    case opCode do
      1 ->
          %{program_state |
            intCodes: add(intCodes, ip),
            ip: ip + instruction_length
        }

      2 ->
          %{program_state |
            intCodes: mul(intCodes, ip),
            ip: ip + instruction_length
      }

      3 ->
        if [] == input do
          %{program_state | wait: true}
        else
            [intInput | input] = input
            %{program_state |
                intCodes: %{intCodes | intCodes[ip + 1] => intInput},
                ip: ip + instruction_length,
                input: input
            }
        end
      4 ->
        %{program_state |
            output: [get_value(intCodes, ip, instruction, 1) | output],
            ip: ip + instruction_length
        }
      5 ->
        if get_value(intCodes, ip, instruction, 1) != 0 do
            %{program_state | ip: get_value(intCodes, ip, instruction, 2)}
        else
            %{program_state | ip: ip + instruction_length}
        end
      6 ->
        if get_value(intCodes, ip, instruction, 1) == 0 do
            %{program_state | ip: get_value(intCodes, ip, instruction, 2)}
        else
            %{program_state | ip: ip + instruction_length}
        end

      7 ->
        if get_value(intCodes, ip, instruction, 1) < get_value(intCodes, ip, instruction, 2) do
            %{program_state |
                intCodes: %{intCodes | intCodes[ip + 3] => 1},
                ip: ip + instruction_length
            }
        else
            %{program_state |
                intCodes: %{intCodes | intCodes[ip + 3] => 0},
                ip: ip + instruction_length
            }
        end

      8 ->
        if get_value(intCodes, ip, instruction, 1) == get_value(intCodes, ip, instruction, 2) do
            %{program_state |
                intCodes: %{intCodes | intCodes[ip + 3] => 1},
                ip: ip + instruction_length
            }
        else
            %{program_state |
                intCodes: %{intCodes | intCodes[ip + 3] => 0},
                ip: ip + instruction_length
            }
        end

      99 -> %{program_state | halt: true}
      _ ->
        raise Integer.to_string(opCode) <> "errorCOMP"
    end
  end

  def get_instruction_length(code) do
    case code do
      1 -> 4
      2 -> 4
      3 -> 2
      4 -> 2
      5 -> 3
      6 -> 3
      7 -> 4
      8 -> 4
      99 -> 0
      _ -> raise Integer.to_string(code) <> "errorIL"
    end
  end

  def run(program_state) do
    if program_state[:halt] or program_state[:wait] do
        program_state
    else
        run(compute(program_state))
    end
  end

  def runAllWithFeedback(amp1,amp2,amp3,amp4,amp5) do
    amp1 = %{amp1 | wait: false}
    amp2 = %{amp2 | wait: false}
    amp3 = %{amp3 | wait: false}
    amp4 = %{amp4 | wait: false}
    amp5 = %{amp5 | wait: false}

    if amp1[:halt] and amp2[:halt] and amp3[:halt] and amp4[:halt] and amp5[:halt] do
        [amp1, amp2, amp3, amp4, amp5]
    else
        amp1_next = IntComputer.run(%{amp1| input: amp1[:input] ++ amp5[:output], wait: false, output: []})
        amp2_next = IntComputer.run(%{amp2| input: amp2[:input] ++ amp1[:output], wait: false, output: []})
        amp3_next = IntComputer.run(%{amp3| input: amp3[:input] ++ amp2[:output], wait: false, output: []})
        amp4_next = IntComputer.run(%{amp4| input: amp4[:input] ++ amp3[:output], wait: false, output: []})
        amp5_next = IntComputer.run(%{amp5| input: amp5[:input] ++ amp4[:output], wait: false, output: []})

        runAllWithFeedback(amp1_next,amp2_next,amp3_next,amp4_next,amp5_next)
    end
  end
end

intCodes =
  File.read!("input.txt")
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer(&1))

intCodes = 0..(length(intCodes) - 1) |> Stream.zip(intCodes) |> Enum.into(%{})
halt = false
ip = 0
output = []

defmodule Helper do
  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
end

program_state = %{id: 0, intCodes: intCodes, ip: ip, halt: halt, input: [], output: [], wait: false}

max2 =
    Helper.permutations([5, 6, 7, 8, 9])
    |> Enum.map(fn input ->
        amp1 = IntComputer.run(%{program_state | id: 1, input: [Enum.at(input, 0), 0]})
        amp2 = IntComputer.run(%{program_state | id: 2, input: [Enum.at(input, 1)]})
        amp3 = IntComputer.run(%{program_state | id: 3, input: [Enum.at(input, 2)]})
        amp4 = IntComputer.run(%{program_state | id: 4, input: [Enum.at(input, 3)]})
        amp5 = IntComputer.run(%{program_state | id: 5, input: [Enum.at(input, 4)]})
        [_amp1, _amp2, _amp3, _amp4, amp5] = IntComputer.runAllWithFeedback(amp1,amp2,amp3,amp4,amp5)

        Enum.at(amp5[:output], 0)
      end)
      |> Enum.max

  IO.inspect(max2)
