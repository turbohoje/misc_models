$fn = 50;
$post_r = 6.3/2;

$height = 35;
$depth   = 100;
$curve_r = $post_r + 4;
$screw_r = 2;
$cut     = 21;

//15mm from cut to hole edge

//offset made from real world measurements and validation with scaffolds
$offset = $depth-$post_r-15;



translate([10,0,0]){
    //cube([10,$offset,1]);
}
translate([10,0,0]){
    //cube([10,$offset-$cut+15,1]);
}

difference(){
    //shape
    hull(){
    translate([0, $depth, 0]){
        cylinder($height, $curve_r, $curve_r);
    }
    translate([0, $depth/2, 0]){
        cylinder($height, $curve_r, $curve_r);
    }
    cylinder(1, $curve_r, $curve_r);
    }

    //frame cut
    translate([-$curve_r-.1, $offset-$cut, -.1]){
        cube([($curve_r+1)*2, $cut, $cut]);
    }
    
    //screw cut
    translate([0, $depth/2, -1]){
        cylinder(3*$height, $screw_r, $screw_r);
    }
    translate([0, $depth/2, $height-($screw_r)+.1]){
        cylinder($screw_r, $screw_r, 2.5*$screw_r);
    }
    
    //post cut
    translate([0, $depth, -5]){
        cylinder($height, $post_r, $post_r);
    }
}