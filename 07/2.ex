defmodule IntComputer do
  def get_op_code(intCode) do
    rem(intCode, 100)
  end

  def get_mode(instruction, parameter) do
    if length(Integer.digits(instruction)) < 2 + parameter do
      0
    else
      Integer.digits(instruction) |> Enum.at(-(2 + parameter))
    end
  end

  def get_value(memory, ip, parameter) do
    if get_mode(memory[ip], parameter) == 1 do
      memory[ip + parameter]
    else
      memory[memory[ip + parameter]]
    end
  end

  def add(memory, ip) do
    %{memory | memory[ip + 3] => get_value(memory, ip, 1) + get_value(memory, ip, 2)}
  end

  def mul(memory, ip) do
    %{memory | memory[ip + 3] => get_value(memory, ip, 1) * get_value(memory, ip, 2)}
  end

  def compute(program_state) do
    memory = program_state.memory
    ip = program_state.ip
    input = program_state.input
    output = program_state.output
    instruction = memory[ip]
    op_code = get_op_code(instruction)
    instruction_length = get_instruction_length(op_code)

    case op_code do
      1 ->
          %{program_state |
            memory: add(memory, ip),
            ip: ip + instruction_length
        }

      2 ->
          %{program_state |
            memory: mul(memory, ip),
            ip: ip + instruction_length
      }

      3 ->
        if [] == input do
          %{program_state | wait: true}
        else
            [intInput | input] = input
            %{program_state |
                memory: %{memory | memory[ip + 1] => intInput},
                ip: ip + instruction_length,
                input: input
            }
        end
      4 ->
        %{program_state |
            output: [get_value(memory, ip, 1) | output],
            ip: ip + instruction_length
        }
      5 ->
        if get_value(memory, ip, 1) != 0 do
            %{program_state | ip: get_value(memory, ip, 2)}
        else
            %{program_state | ip: ip + instruction_length}
        end
      6 ->
        if get_value(memory, ip, 1) == 0 do
            %{program_state | ip: get_value(memory, ip, 2)}
        else
            %{program_state | ip: ip + instruction_length}
        end

      7 ->
        if get_value(memory, ip, 1) < get_value(memory, ip, 2) do
            %{program_state |
                memory: %{memory | memory[ip + 3] => 1},
                ip: ip + instruction_length
            }
        else
            %{program_state |
                memory: %{memory | memory[ip + 3] => 0},
                ip: ip + instruction_length
            }
        end

      8 ->
        if get_value(memory, ip, 1) == get_value(memory, ip, 2) do
            %{program_state |
                memory: %{memory | memory[ip + 3] => 1},
                ip: ip + instruction_length
            }
        else
            %{program_state |
                memory: %{memory | memory[ip + 3] => 0},
                ip: ip + instruction_length
            }
        end

      99 -> %{program_state | halt: true}
      _ ->
        raise Integer.to_string(op_code) <> "errorCOMP"
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
    if program_state.halt or program_state.wait do
        program_state
    else
        run(compute(program_state))
    end
  end

  def run_all_with_feedback_loop(amps) do
    amps = Enum.map(amps, fn amp -> %{amp | wait: false} end)

    if Enum.reduce(amps, true, fn(cur, acc) -> acc && cur.halt end) do
      amps
    else
      Enum.with_index(amps)
      |> Enum.map(fn({amp, index}) -> IntComputer.run(%{amp| input: amp.input ++ Enum.at(amps, rem(index+4, 5)).output, output: []}) end)
      |> run_all_with_feedback_loop

    end
  end
end

defmodule Helper do
  def permutations([]) do
    [[]]
  end

  def permutations(list) do
    for(elem <- list, rest <- permutations(list -- [elem]), do:
      [elem | rest]
    )
  end
end

memory =
  File.read!("input.txt")
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer(&1))
  |> Enum.with_index
  |> Enum.map(fn({x, y}) -> {y, x} end)
  |> Enum.into(%{})
halt = false
ip = 0

program_state = %{id: 0, memory: memory, ip: ip, halt: halt, input: [], output: [], wait: false}

max2 =
  Helper.permutations([5, 6, 7, 8, 9])
  |> Enum.map(fn input ->
      amps = input |> Enum.map(fn(setting) -> IntComputer.run(%{program_state | input: [setting]}) end)
      [head | tail] = amps
      head = IntComputer.run(%{head | input: [0]})
      amps = [head | tail]
      amps = IntComputer.run_all_with_feedback_loop(amps)

      Enum.at(List.last(amps).output, 0)
    end)
  |> Enum.max

IO.inspect(max2)
