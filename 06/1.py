input = open("input.txt","r").read().strip().split("\n")

orbits = {}
planets = set()
for orbit in input:
    print orbit
    orbitee, orbiter = orbit.split(')')
    orbits[orbiter] = orbitee
    planets.add(orbiter)
    planets.add(orbitee)

def orbit_checksum(planet):
    sum = 0
    while planet in orbits:
        planet = orbits[planet]
        sum += 1

    return sum

sum = 0
for planet in planets:
    sum += orbit_checksum(planet)

print sum