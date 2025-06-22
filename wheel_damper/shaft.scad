// Parameters
outer_dia = 16;
shaft_diameter = 4.95;         // Diameter of round part
flat_dia = 4.01;              // Width between flats
height = 8;
flats_offset = (shaft_diameter - flat_width) / 2;

$fn = 100;  // Resolution

difference() {
    // Main outer cylinder
    cylinder(h = height, r = outer_dia/2);

    // Shaft with dual flats (union of cylinder and two cubes cutting off the sides)
    translate([0, 0, -.5])
        shaft_with_flats(shaft_diameter, flat_dia, height + 1);
}

// Module to generate a dual-flat shaft
module shaft_with_flats(dia, dia_flat, h) {
    base_size = 10;
   

    difference() {
        // Base round shaft
        cylinder(h = h, r = dia / 2);

        // Flat cuts - subtract from both sides
        translate([dia_flat/2, -base_size/2, -.1])
            cube([base_size, base_size, h + 1], center = false);
        rotate([0,0,180])
        translate([dia_flat/2, -base_size/2, -.1])
            cube([base_size, base_size, h + 1], center = false);
    }
}