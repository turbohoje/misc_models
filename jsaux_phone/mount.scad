$fn = 100;

$diameter = 75;
$thick = 10;
$nut_dia = 10;
$shaft_dia = 4;

difference(){
    hull(){
        linear_extrude(1)
        circle($diameter / 2);
        translate([0,0,$thick]){
            linear_extrude(1)
            circle($nut_dia/2);
        }
    }

    //shaft
    translate([0,0,-1])
    cylinder(h = $thick+3, r=$shaft_dia/2);
    
    //nut
    translate([0,0,-.01])
    cylinder(h = $thick-1, r=$nut_dia/2, $fn=6);
    
    //cutaway
    translate([0,-50,-1])
    cube([100,100,100]);
}