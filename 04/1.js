let min = 359282
let max = 820401

function hasAscendingDigits(min, numberArg){
    let number = numberArg + '';
    if(number===''){
        return true;
    }
    let firstDigit = number[0];

    if(firstDigit >= min){
        return hasAscendingDigits(firstDigit, number.substring(1));
    }else{
        return false;
    }
}

function hasDoubleDigits(digit, numberArg){
    let number = numberArg + '';
    let firstDigit = number[0];
    if(number === ''){
        return false;
    }
    if(digit == firstDigit){
        return true;
    }else{
        return hasDoubleDigits(firstDigit, number.substring(1));
    }
}

let matchingNumbers = [];
for(let i = min; i < max; i++){
    if(hasAscendingDigits(0, i) && hasDoubleDigits(0, i)){
        matchingNumbers.push(i);
    }
}

console.log(matchingNumbers.length);

function hasOnlyDoubleDigits(numberArg){
    let number = numberArg + '';

    let histogram = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    for(let digit of number){
        histogram[digit]++;
    }

    let hasDouble = false;
    let hasTriple = false;
    for(let column of histogram){
        if(column==2){
            hasDouble = true
        }
        if(column > 2){
            hasTriple = true;
        }
    }

    return hasDouble;
}

let betterMatchingNumbers = [];
for(let n of matchingNumbers){
    if(hasOnlyDoubleDigits(n)){
        betterMatchingNumbers.push(n);
    }
}

console.log(betterMatchingNumbers.length);