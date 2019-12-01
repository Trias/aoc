use std::fs;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>>{
    let string_content: String = fs::read_to_string("data/input.txt")?;
    let masses: &mut dyn Iterator<Item = i32> = 
        &mut string_content
            .split("\n")
           // .filter(|string| !string.is_empty())
            .map(|item| item.parse::<i32>().unwrap());
    
    let fuel = calc_fuel(masses);

    println!("{:?}", fuel);

    Ok(())
}

fn calc_fuel(masses: &mut dyn Iterator<Item = i32>) -> i32{
    masses
        .map(calc_fuel_for_mass)
        .fold(0, |prev, cur| prev + cur)
}

fn calc_fuel_for_mass(mass: i32) -> i32 {
    let fuel = mass / 3 - 2;
    if fuel < 0 {0} else {fuel + calc_fuel_for_mass(fuel)}
}