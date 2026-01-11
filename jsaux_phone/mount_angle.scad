$fn = 100;

$diameter = 56;
$thick = 10;
$face_dia = 11;
$shaft_dia = 5.61;

difference(){
    hull(){
            cylinder(1, $diameter / 2, $diameter / 2);
        
        
        translate([$diameter/4,0,$thick]){
            rotate([0,30,0]){
                cylinder(h=1, $face_dia/2, $face_dia/2);
            

            }
        }
    }//hull


    
    //shaft
    translate([$diameter/4,0,$thick]){
    rotate([0,30,0]){

    cylinder(h = $thick*3, r=$shaft_dia/2, center=true);
    
    }
    }
}