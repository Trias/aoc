-module(aoc).
-export([start/0]).

readlines(FileName) ->
    {ok, Device} = file:open(FileName, [read]),
    try get_all_lines(Device)
      after file:close(Device)
    end.

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof  -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

chunk(String, Size) ->
    if 
        erlang:length(String) =< Size -> 
            [String];
        true ->
            [string:slice(String, 0, Size) | chunk(string:slice(String, Size), Size)]
    end.

histogram(Chunk) ->
    lists:foldl(fun(Char, Map) -> 
        maps:update_with(
            Char - 48, 
            fun(Value) ->
                Value + 1 
            end, 
            1,
            Map) 
        end, 
        #{}, 
        Chunk).

minByFun(Fun, Items) ->
    First = {lists:nth(1, Items), Fun(lists:nth(1, Items))},
    lists:foldl(
        fun(Item, {MinItem, Min}) -> 
            case Min > Fun(Item) of
                true -> {Item, Fun(Item)};
                false -> {MinItem, Min}
            end
        end,
        First,
        Items).

charToInteger(Char) -> 
    Char - 48.

integerToChar(Int) -> 
    Int + 48.

render(Chunks) ->
    lists:foldl(
        fun(Chunk, Prev) -> 
            lists:map(
                fun(Tupel) ->
                    case Tupel of
                        {_, 0} -> 0;
                        {_, 1} -> 1;
                        {Color, 2} -> Color;
                        _ -> io:format(Tupel,Chunk, Prev),throw("error")
                    end
                end, 
                lists:zip(lists:map(fun charToInteger/1, Chunk), Prev)
            ) 
        end, 
        lists:map(fun charToInteger/1, lists:nth(1, Chunks)),
        Chunks
    ).

start() ->
    Input = string:chomp(readlines("input.txt")),
    Width = 25,
    Height = 6,
    Chunks = chunk(Input, Width*Height),
    Histograms = lists:map(fun histogram/1, Chunks),
    {MostZeroHistogram, _Min} = minByFun(
        fun(Histogram) -> maps:get(0, Histogram, 0) end, 
        Histograms),
    Solution = maps:get(1, MostZeroHistogram, 0) * maps:get(2, MostZeroHistogram, 0),
    io:format(integer_to_list(Solution)),
    io:format("~n"),
    Image = chunk(lists:map(fun integerToChar/1, render(Chunks)), 25),
    lists:foreach(fun (Line) ->  io:format(Line ++ "~n") end, Image).