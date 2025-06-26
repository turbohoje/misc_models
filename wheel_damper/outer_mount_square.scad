// Parameters
outer_dia = 115;
mount_dia = 103;
hole_dia  = 29;
inner_mount_dia = 76; //spacing of screws on damper
inner_mount_hole = 3.5; //inner screws

outer_mount_shaft = 6;
outer_mount_head = 11;

sidecut = 21;

height = 21;


$fn = 100;  // Resolution

difference(){
// Main outer cylinder
    hull(){
        cylinder(h = .1, r = outer_dia/2);
        translate([0,0,height])
            cylinder(h = .1, r = inner_mount_dia/2+10);
    }
    
    //center hole
    translate([0,0,-0.1])
        cylinder(r=hole_dia/2, h=height+1);

    //sides
    translate([sidecut,-outer_dia/2,-.1])
        cube([outer_dia, outer_dia, outer_dia]);
    rotate([0,0,180])
    translate([sidecut,-outer_dia/2,-.1])
        cube([outer_dia, outer_dia, outer_dia]);
    
    //mount holes for damper
    translate([0,inner_mount_dia/2,-0.1])
        cylinder(h = height*2, r=inner_mount_hole/2);
    translate([0,-inner_mount_dia/2,-0.1])
        cylinder(h = height*2, r=inner_mount_hole/2);
    
    translate([0,mount_dia/2,1])
        bolt_hole(outer_mount_head, outer_mount_shaft);
    
    rotate([0,0,180])
    translate([0,mount_dia/2,1])
        bolt_hole(outer_mount_head, outer_mount_shaft);
        
    //shaft to straddle
    translate([0,0,-.01])
    cylinder(r=39/2, h=18);

}

module bolt_hole(l, s) {
    plenty=50;
    taper=3;
    
    translate([0,0,taper-.01])
    cylinder(r=l/2, h=plenty);
    translate([0,0,0])
    cylinder(taper, s/2, l/2);
    translate([0,0,-plenty+.01])
    cylinder(r=s/2, h=plenty);


}