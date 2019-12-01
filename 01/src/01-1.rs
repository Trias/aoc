use std::fs;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>>{
    let file = fs::read("data/input.txt");
    let sum: i32 = String::from_utf8_lossy(&file?).split("\n")
        .filter(|string| !string.is_empty())
        .map(|item| item.parse::<i32>().unwrap() / 3 - 2)
        .fold(0, |prev, cur| prev + cur);

    println!("{:?}", sum);
    Ok(())
}