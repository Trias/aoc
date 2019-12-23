main:-
    read_file("input.txt", Map),
    %writePrettyMap(Map),
    findAsteroids(Map, 0, Asteroids),
    rayCasting(Asteroids, Asteroids, VisibleAsteroidsByAsteroid),
    bestAsteroid(VisibleAsteroidsByAsteroid, BestAsteroid, _, 0, Count, _, _),
    writeTupel(BestAsteroid),
    write(Count).
    %writeTupels(Asteroids).

main2:-
    read_file("input.txt", Map),
    %writePrettyMap(Map),
    findAsteroids(Map, 0, Asteroids),
    rayCasting(Asteroids, Asteroids, VisibleAsteroidsByAsteroid),
    bestAsteroid(VisibleAsteroidsByAsteroid, BestAsteroid, _, 0, _, _, RaysOut),
    sortClockwise(RaysOut, SortedRays),
    shootLaserAndRotate(BestAsteroid, SortedRays, Asteroids, 200, _, XHit),
    write(XHit).

sortClockwise(Rays, SortedRays):-
    predsort(clockWiseCompare, Rays, SortedRays).

clockWiseCompare(Delta, direction(X1, Y1), direction(X2, Y2)):-
    D2 is atan2(X2, Y2),
    D1 is atan2(X1, Y1),
    compare(Delta, D2, D1).

shootLaserAndRotate(_, _, _, 0, LastHit, LastHit):-!.
shootLaserAndRotate(Position, [Ray|SortedRays], Asteroids, Count, LastHit, XHit):-
    shoot(Position, Ray, Asteroids, NewAsteroids, Hit)
    -> append(SortedRays, [Ray], NewSortedRays), NewCount is Count - 1, shootLaserAndRotate(Position, NewSortedRays, NewAsteroids, NewCount, Hit, XHit)
    ;  append(SortedRays, [Ray], NewSortedRays), shootLaserAndRotate(Position, NewSortedRays, Asteroids, Count, LastHit, XHit).

shoot(coords(X, Y), Direction, Asteroids, NewAsteroids, Hit):-
    (X=<36, Y=<36, X>=0, Y>=0)
    -> shootInBounds(coords(X,Y), Direction, Asteroids, NewAsteroids, Hit)
    ;  fail.

shootInBounds(coords(X,Y),direction(DiffX, DiffY), Asteroids, NewAsteroids, Hit) :-
    NewX is X + DiffX,
    NewY is Y + DiffY,
    PossibleHit = coords(NewX, NewY),
    (member(PossibleHit, Asteroids) 
    -> (Hit = PossibleHit, delete(Asteroids, PossibleHit, NewAsteroids))
    ;  shoot(PossibleHit, direction(DiffX, DiffY), Asteroids, NewAsteroids, Hit)).

bestAsteroid([], BestAsteroid, BestAsteroid, Count, Count, Rays, Rays).
bestAsteroid([visible(Head, FilteredRaysToOtherAsteroids)|VisibleAsteroidsByAsteroid], BestAsteroid, BestAsteroidSoFar, Count, CountOut, Rays, RaysOut) :-
    length(FilteredRaysToOtherAsteroids, VisibleAsteroidsCount),
    VisibleAsteroidsCount > Count 
        -> bestAsteroid(VisibleAsteroidsByAsteroid, BestAsteroid, Head, VisibleAsteroidsCount, CountOut, FilteredRaysToOtherAsteroids, RaysOut)
        ;  bestAsteroid(VisibleAsteroidsByAsteroid, BestAsteroid, BestAsteroidSoFar, Count, CountOut, Rays, RaysOut).

rayCasting([], _, _) :- !.
rayCasting([Head|Tail], Asteroids, NewUniqueRaysToOtherAsteroidsByAsteroid) :-
    raysToAllOtherAsteroids(Head, Asteroids, RaysToOtherAsteroids),
    filterHiddenAsteroids(RaysToOtherAsteroids, UniqueRaysToOtherSatellites),
    rayCasting(Tail, Asteroids, UniqueRaysToOtherAsteroidsByAsteroid),
    append([visible(Head, UniqueRaysToOtherSatellites)], UniqueRaysToOtherAsteroidsByAsteroid, NewUniqueRaysToOtherAsteroidsByAsteroid).

raysToAllOtherAsteroids(_, [], _) :- !.
raysToAllOtherAsteroids(Asteroid, [OtherAsteroid|OtherAsteroids], NewRaysToOtherAsteroids) :-
    raysToAllOtherAsteroids(Asteroid, OtherAsteroids, RaysToOtherAsteroids),   
    coords(OtherAsteroidX, OtherAsteroidY) = OtherAsteroid,
    coords(AsteroidX, AsteroidY) = Asteroid,
    DiffX is OtherAsteroidX-AsteroidX,
    DiffY is OtherAsteroidY-AsteroidY,
    appendIfNotPointZero(direction(DiffX, DiffY), RaysToOtherAsteroids, NewRaysToOtherAsteroids).

appendIfNotPointZero(direction(0,0), RaysToOtherAsteroids, RaysToOtherAsteroids):-!.
appendIfNotPointZero(Direction, RaysToOtherAsteroids, NewRaysToOtherAsteroids) :-
    append([Direction], RaysToOtherAsteroids, NewRaysToOtherAsteroids).

filterHiddenAsteroids(Rays, UniqueRays) :-
    maplist(normalizeRay, Rays, NormalizedRays),
    list_to_set(NormalizedRays, UniqueRays).

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