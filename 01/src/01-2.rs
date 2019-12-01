use std::fs;
use std::str::Split;

fn main() {
    let file = &fs::read("data/input.txt");
    let unwrap: Vec<u8> = file.as_ref().unwrap().to_vec();
    let string_content: String = String::from_utf8_lossy(&unwrap).to_string();
    let string_iter: Split<&str> = string_content.split("\n");
    let masses: Vec<i32> = string_iter
        .filter(|string| !string.is_empty())
        .map(|item| item.parse().unwrap())
        .collect();
    
    let fuel = calc_fuel(masses);

    println
    !("{:?}", fuel);
}

fn calc_fuel(masses: Vec<i32>) -> i32{
    let fuel = masses.into_iter()
    .map(calc_fuel_for_mass)
    .fold(0, |prev, cur| prev + cur);
    return fuel;
}

fn calc_fuel_for_mass(mass: i32) -> i32 {
    let fuel = mass / 3 - 2;
    if fuel < 0 {
        return 0;
    }else{
        return fuel + calc_fuel_for_mass(fuel);
    }
}