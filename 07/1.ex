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

  def compute(intCodes, ip, halt, input, output) do
    instruction = intCodes[ip]
    opCode = get_op_code(instruction)
    instruction_length = get_instruction_length(opCode)

    case opCode do
      1 ->
        [
          %{
            intCodes
            | intCodes[ip + 3] =>
                get_value(intCodes, ip, instruction, 1) + get_value(intCodes, ip, instruction, 2)
          },
          ip + instruction_length,
          halt,
          input,
          output
        ]

      2 ->
        [
          %{
            intCodes
            | intCodes[ip + 3] =>
                get_value(intCodes, ip, instruction, 1) * get_value(intCodes, ip, instruction, 2)
          },
          ip + instruction_length,
          halt,
          input,
          output
        ]

      3 ->
        [intInput | input] = input
        [%{intCodes | intCodes[ip + 1] => intInput}, ip + instruction_length, halt, input, output]

      4 ->
        output = output ++ [get_value(intCodes, ip, instruction, 1)]
        [intCodes, ip + instruction_length, halt, input, output]

      5 ->
        if get_value(intCodes, ip, instruction, 1) != 0 do
          [intCodes, get_value(intCodes, ip, instruction, 2), halt, input, output]
        else
          [intCodes, ip + instruction_length, halt, input, output]
        end

      6 ->
        if get_value(intCodes, ip, instruction, 1) == 0 do
          [intCodes, get_value(intCodes, ip, instruction, 2), halt, input, output]
        else
          [intCodes, ip + instruction_length, halt, input, output]
        end

      7 ->
        if get_value(intCodes, ip, instruction, 1) < get_value(intCodes, ip, instruction, 2) do
          [%{intCodes | intCodes[ip + 3] => 1}, ip + instruction_length, halt, input, output]
        else
          [%{intCodes | intCodes[ip + 3] => 0}, ip + instruction_length, halt, input, output]
        end

      8 ->
        if get_value(intCodes, ip, instruction, 1) == get_value(intCodes, ip, instruction, 2) do
          [%{intCodes | intCodes[ip + 3] => 1}, ip + instruction_length, halt, input, output]
        else
          [%{intCodes | intCodes[ip + 3] => 0}, ip + instruction_length, halt, input, output]
        end

      99 ->
        [intCodes, ip + instruction_length, true, input, output]

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
      99 -> 1
      _ -> raise Integer.to_string(code) <> "errorIL"
    end
  end

  def run([intCodes, ip, halt, input, output]) do
    if halt do
      [intCodes, ip, halt, input, output]
    else
      run(compute(intCodes, ip, halt, input, output))
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
input = [0, 1, 2, 3, 4]
output = []

defmodule Helper do
  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
end

max =
  Helper.permutations([0, 1, 2, 3, 4])
  |> Enum.map(fn input ->
      [_intCodes, _ip, _halt, _input, output] = IntComputer.run([intCodes, ip, halt, [Enum.at(input, 0), Enum.at(output, 0, 0)], []])
      [_intCodes, _ip, _halt, _input, output] = IntComputer.run([intCodes, ip, halt, [Enum.at(input, 1), Enum.at(output, 0, 0)], []])
      [_intCodes, _ip, _halt, _input, output] = IntComputer.run([intCodes, ip, halt, [Enum.at(input, 2), Enum.at(output, 0, 0)], []])
      [_intCodes, _ip, _halt, _input, output] = IntComputer.run([intCodes, ip, halt, [Enum.at(input, 3), Enum.at(output, 0, 0)], []])
      [_intCodes, _ip, _halt, _input, output] = IntComputer.run([intCodes, ip, halt, [Enum.at(input, 4), Enum.at(output, 0, 0)], []])
      Enum.at(output, 0)
    end)
    |> Enum.max

IO.inspect(max)
