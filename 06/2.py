input = open("input.txt","r").read().strip().split("\n")

planets = set()
satelliteToPlanet = {}
planetToSatellite = {}
for orbit in input:
    planet, satellite = orbit.split(')')
    satelliteToPlanet[satellite] = planet
    if planet in planetToSatellite:
        planetToSatellite[planet].add(satellite)
    else:
        planetToSatellite[planet] = {satellite}
    planets.add(satellite)
    planets.add(planet)

def neighbors(body):
    nb = set()
    if body in planetToSatellite:
        nb = planetToSatellite[body].copy()
    if(body in satelliteToPlanet):
        nb.add(satelliteToPlanet[body])
    return nb

def bfs(source, dest):
    if satelliteToPlanet[source] == satelliteToPlanet[dest]:
        return 0
    step = 0
    visited = {source}
    edgePlanets = neighbors(source) - visited

    while len(edgePlanets):
        for edgePlanet in edgePlanets:
            if edgePlanet == satelliteToPlanet[dest]:
                return step
            visited.add(edgePlanet)
        step += 1
        edgePlanets = {n for e in edgePlanets for n in neighbors(e)} - visited
    return 'error, no route found' 

print bfs('YOU', 'SAN')