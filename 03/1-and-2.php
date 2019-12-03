<?php

error_reporting(E_ALL);

$input = explode("\n", file_get_contents('input.txt'));

$wires = [];
foreach($input as $key => $wire){
    $wires[] = explode(",", $input[$key]);
}

$coordinatesOfWire0 = getCoordiatesOf($wires[0]);
$coordinatesOfWire1 = getCoordiatesOf($wires[1]);

$intersection = array_intersect($coordinatesOfWire0, $coordinatesOfWire1);

usort($intersection, function($coordinateString1, $coordinateString2){
    $coordinate1 = explode(',', $coordinateString1);
    $coordinate2 = explode(',', $coordinateString2);
    return (abs($coordinate1[0]) + abs($coordinate1[1])) - (abs($coordinate2[0]) + abs($coordinate2[1]));
});

$nearestCross = explode(",", $intersection[0]);

echo "\nmanhattandistance: ". (abs($nearestCross[0]) + abs($nearestCross[1]));

usort($intersection, function($coordinateString1, $coordinateString2){
    return stepCount($coordinateString1) - stepCount($coordinateString2);
});

function stepCount($coordinate){
    global $coordinatesOfWire0, $coordinatesOfWire1;
    return array_search($coordinate, $coordinatesOfWire0) + array_search($coordinate, $coordinatesOfWire1);
}

echo "\nshortest steps: ". (array_search($intersection[0], $coordinatesOfWire0) + array_search($intersection[0], $coordinatesOfWire1) + 2);
echo "\n";

function getCoordiatesOf($wire){
    $currentCoordiate = [0,0];
    $allCoordiates = [];
    while(count($wire)){
        $directive = array_shift($wire);
        $direction = $directive[0];
        $directionDistance = (int)substr($directive, 1);

        for(; $directionDistance > 0; $directionDistance--){

            if($direction == "U"){
                $currentCoordiate[1]++;
            }else if($direction == "D"){
                $currentCoordiate[1]--;
            }else if($direction == "R"){
                $currentCoordiate[0]++;
            }else if($direction == "L"){
                $currentCoordiate[0]--;
            }else{
                throw new \Exception();
            }

            $allCoordiates[] = $currentCoordiate[0].','.$currentCoordiate[1];
        }
    }

    return $allCoordiates;
}