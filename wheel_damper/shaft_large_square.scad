// Parameters
outer_dia = 16;
shaft_diameter = 4.95;         // Diameter of round part
flat_dia = 4.01;              // Width between flats
height = 8;
flats_offset = (shaft_diameter - flat_width) / 2;

$fn = 100;  // Resolution


    // Main outer cylinder
    cylinder(h = height, r = outer_dia/2);
    translate([0,0,height+(9/2)])
        cube([12,12,9], center=true);

