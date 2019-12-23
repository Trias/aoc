main:-
    read_file("input.txt", Map),
    %writePrettyMap(Map),
    findAsteroids(Map, 0, Asteroids),
    rayCasting(Asteroids, Asteroids, VisibleAsteroidsByAsteroid),
    bestAsteroid(VisibleAsteroidsByAsteroid, BestAsteroid, _, 0, Count),
    writeTupel(BestAsteroid),
    CountWithoutMe is Count -1,
    write(CountWithoutMe).
    %writeTupels(Asteroids).

bestAsteroid([], BestAsteroid, BestAsteroid, Count, Count).
bestAsteroid([visible(Head, FilteredRaysToOtherAsteroids)|VisibleAsteroidsByAsteroid], BestAsteroid, BestAsteroidSoFar, Count, CountOut) :-
    length(FilteredRaysToOtherAsteroids, VisibleAsteroidsCount),
    VisibleAsteroidsCount > Count 
        -> bestAsteroid(VisibleAsteroidsByAsteroid, BestAsteroid, Head, VisibleAsteroidsCount, CountOut)
        ;  bestAsteroid(VisibleAsteroidsByAsteroid, BestAsteroid, BestAsteroidSoFar, Count, CountOut).


rayCasting([], _, NewUniqueRaysToOtherAsteroidsByAsteroid) :- NewUniqueRaysToOtherAsteroidsByAsteroid = [].
rayCasting([Head|Tail], Asteroids, NewUniqueRaysToOtherAsteroidsByAsteroid) :-
    raysToAllOtherAsteroids(Head, Asteroids, RaysToOtherAsteroids),
    filterHiddenAsteroids(RaysToOtherAsteroids, UniqueRaysToOtherSatellites),
    rayCasting(Tail, Asteroids, UniqueRaysToOtherAsteroidsByAsteroid),
    append([visible(Head, UniqueRaysToOtherSatellites)], UniqueRaysToOtherAsteroidsByAsteroid, NewUniqueRaysToOtherAsteroidsByAsteroid).

raysToAllOtherAsteroids(_, [], NewRaysToOtherAsteroids) :- NewRaysToOtherAsteroids = [].
raysToAllOtherAsteroids(Asteroid, [OtherAsteroid|OtherAsteroids], NewRaysToOtherAsteroids) :-
    coords(OtherAsteroidX, OtherAsteroidY) = OtherAsteroid,
    coords(AsteroidX, AsteroidY) = Asteroid,
    raysToAllOtherAsteroids(Asteroid, OtherAsteroids, RaysToOtherAsteroids),
    DiffX is OtherAsteroidX-AsteroidX,
    DiffY is OtherAsteroidY-AsteroidY,
    append([direction(DiffX, DiffY)], RaysToOtherAsteroids, NewRaysToOtherAsteroids).

filterHiddenAsteroids(Rays, UniqueRays) :-
    maplist(normalizeRay, Rays, NormalizedRays),
    list_to_set(NormalizedRays, UniqueRays).

addRayIfUnique(Ray, [], NewUniqueRaysToOtherAsteroids) :-
    NewUniqueRaysToOtherAsteroids = [Ray].
addRayIfUnique(Ray, UniqeRaysToOtherAsteroids, NewUniqueRaysToOtherAsteroids) :-
    (not(member(Ray, UniqeRaysToOtherAsteroids); Ray = direction(0,0))) -> append(Ray, UniqeRaysToOtherAsteroids, NewUniqueRaysToOtherAsteroids);true.

normalizeRay(direction(X,Y), NormalizedRay) :-
    ((X =:= 0, Y =:= 0) -> NormalizedRay = direction(0, 0)
    ; X =:= 0, Y > 0 -> NormalizedRay = direction(0, 1)
    ; X =:= 0, Y < 0 -> NormalizedRay = direction(0, -1)
    ; Y =:= 0, X > 0 -> NormalizedRay = direction(1, 0)
    ; Y =:= 0, X < 0 -> NormalizedRay = direction(-1, 0)
    ; (gcd(X, Y) =:= 1) 
        ->  NormalizedRay = direction(X, Y)
        ;   A is gcd(X, Y),
            NewX is div(X, A),
            NewY is div(Y, A),
            normalizeRay(direction(NewX, NewY), NormalizedRay)).

findAsteroids([], _, []).
findAsteroids([Head|Tail], Y, NewAsteroids) :-
   % format("line: ~w\n", Y),
    findAsteroidsInLine(Head, 0, Y, AsteroidsInLine),
    Y1 is Y + 1,
    %format("line: ~w\n", Y1),
    findAsteroids(Tail, Y1, Asteroids),
    append(AsteroidsInLine, Asteroids, NewAsteroids).

findAsteroidsInLine([], _, _, []).
findAsteroidsInLine([Head|Tail], X, Y, NewAsteroidsInLine) :-
    X1 is X + 1,
    %format("row,col: ~w\n", (X,Y)),
    findAsteroidsInLine(Tail, X1, Y, AsteroidsInLine),
    addAsteroid(Head, coords(X, Y), AsteroidsInLine, NewAsteroidsInLine).
    %writeTuples(NewAsteroidsInLine).

addAsteroid(35, Coords, Asteroids, [Coords|Asteroids]).
addAsteroid(46, _, Asteroids, Asteroids).

read_file(File, Result):-
    open(File, read, Stream),
    read_line(Stream, Result), !,
    close(Stream).

read_line(Stream, []) :- 
    at_end_of_stream(Stream).

read_line(Stream, [X|Result]) :-
    read_line_to_codes(Stream, X),
    read_line(Stream, Result).

writePrettyMap([]).
writePrettyMap([Head|Tail]) :-
    writePrettyLine(Head),
    nl,
    writePrettyMap(Tail).

writePrettyLine([]).
writePrettyLine([Head|Tail]) :-
    writeChar(Head),
    writePrettyLine(Tail).

writeChar(46) :- write(".").
writeChar(35) :- write("#").

writeTuples([]) :- nl.
writeTupels([Head|Tail]) :- 
    writeTupel(Head),
    writeTuples(Tail).

writeTupel(X) :- format("~w,", X).