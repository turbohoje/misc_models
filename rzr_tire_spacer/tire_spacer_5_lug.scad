// Tire Hanger Face - 2D Profile with Hull to Circle
// Wide at TOP, narrow at BOTTOM
// Origin at center-bottom of the trapezoid
// All dimensions in mm

$fn = 60;

// Main trapezoid dimensions
top_width = 215.9;       // 8.5"
bottom_width = 88.9;     // 3.5"
height = 203.2;          // 8.0"

// Two horizontal rectangular slots near the TOP (wide end)
slot_width = 63.5;       // 2.5"
slot_height = 12.7;      // 0.5"
slot_y_from_top = 25.4;  // 1.0" down from top edge
slot_y_center = height - slot_y_from_top;  // from bottom origin
slot_gap = 31.75;        // 1.25" gap between inner edges

// Vertical slot in center of face
vert_slot_width = 12.7;        // 0.5"
vert_slot_height = 103.5;      // ~4.07"
vert_slot_top_from_top = 85.8; // down from top edge
vert_slot_y_center = height - vert_slot_top_from_top - vert_slot_height/2;

// Hull parameters
hull_height = 176.2;       // 3" up the Z axis (parameterized)
circle_diameter = 228.6;  // 9" diameter (parameterized)

// Hub center position (from bolt pattern analysis)
hub_center_y = height - 71.6;  // 131.6mm from bottom

// Bolt pattern parameters
bolt_pcd = 114.3;              // pitch circle diameter
bolt_radius = bolt_pcd / 2;    // 57.15mm
lug_hole_diameter = 12.7;      // 0.5" lug hole — parameterized

// Hub recess parameters
hub_recess_diameter = 80;      // parameterized
hub_recess_depth = 25.4;       // 1" deep into the shape from top face

// Nut recess parameters
nut_recess_diameter = 22;      // across-flats size for nut (parameterized)
nut_recess_depth = 10;         // depth of hex recess into top face (parameterized)

// Lug positions (from bolt pattern analysis)
lug_a_x = -33.6;
lug_a_y = slot_y_center;
lug_b_x = 33.6;
lug_b_y = slot_y_center;
lug_d_x = 0;
lug_d_y = hub_center_y - bolt_radius;

// --- Modules ---

module main_outline() {
    offset(r = 3.81)
    offset(delta = -3.81)
    polygon(points = [
        [-bottom_width/2, 0],
        [-top_width/2, height],
        [ top_width/2, height],
        [ bottom_width/2, 0]
    ]);
}

module left_slot() {
    translate([-(slot_gap/2 + slot_width/2), slot_y_center])
        offset(r = 2.032)
        offset(delta = -2.032)
        square([slot_width, slot_height], center = true);
}

module right_slot() {
    translate([(slot_gap/2 + slot_width/2), slot_y_center])
        offset(r = 2.032)
        offset(delta = -2.032)
        square([slot_width, slot_height], center = true);
}

module center_vert_slot() {
    translate([0, vert_slot_y_center])
        offset(r = 2.032)
        offset(delta = -2.032)
        square([vert_slot_width, vert_slot_height], center = true);
}

module tire_hanger_face() {
    difference() {
        main_outline();
        left_slot();
        right_slot();
        center_vert_slot();
    }
}

module lug_hole() {
    cylinder(h = hull_height * 3, d = lug_hole_diameter, center = true);
}

module nut_recess() {
    // Hex nut recess cut from the top face downward
    translate([0, 0, hull_height - nut_recess_depth])
        cylinder(h = nut_recess_depth + 1, d = nut_recess_diameter, $fn = 6);
}

// --- Final Shape ---

difference() {
    // Hull: base face to circle
    hull() {
        linear_extrude(height = 0.01)
            tire_hanger_face();

        translate([0, hub_center_y, hull_height])
            linear_extrude(height = 0.01)
            circle(d = circle_diameter);
    }

    // Cut lug holes through entire shape
    translate([lug_a_x, lug_a_y, 0])
        lug_hole();

    translate([lug_b_x, lug_b_y, 0])
        lug_hole();

    translate([lug_d_x, lug_d_y, 0])
        lug_hole();

    // Hex nut recesses — centered on each lug hole, cut from top face
    translate([lug_a_x, lug_a_y, 0])
        nut_recess();

    translate([lug_b_x, lug_b_y, 0])
        nut_recess();

    translate([lug_d_x, lug_d_y, 0])
        nut_recess();

    // Hub recess — cylinder cut from the top circle face downward
    translate([0, hub_center_y, hull_height - hub_recess_depth])
        cylinder(h = hub_recess_depth + 1, d = hub_recess_diameter);
}