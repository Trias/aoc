use std::fs;
use std::str::Split;

fn main() {
    let file = &fs::read("data/input.txt");
    let unwrap: Vec<u8> = file.as_ref().unwrap().to_vec();
    let string_content: String = String::from_utf8_lossy(&unwrap).to_string();
    let string_iter: Split<&str> = string_content.split("\n");
    let inputs: Vec<i32> = string_iter
        .filter(|string| !string.is_empty())
        .map(|item| item.parse().unwrap())
        .collect();
    
    let sum = inputs.into_iter()
        .map(|input| input / 3 - 2)
        .fold(0, |prev, cur| prev + cur);

    println!("{:?}", sum);
}