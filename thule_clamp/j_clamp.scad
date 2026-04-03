// J Clamp Profile
// All dimensions in mm

// --- Parameters ---
back_height = 50+14;  // height of the vertical back stem
inner_d     = 50;     // inside diameter of the J curve
stroke_w    = 18;     // thickness of all strokes
depth       = 18;     // extrusion depth (thickness into Z)
bolt_d      = 9;      // diameter of bolt hole through center of back stem
chamfer     = 2;      // chamfer size on top and bottom outside edges

$fn = 120;

// --- Derived ---
inner_r = inner_d / 2;
outer_r = inner_r + stroke_w;
width   = outer_r * 2;

// --- 2D Profile ---
module arch_2d() {
    translate([outer_r, outer_r]) {
        difference() {
            circle(r = outer_r);
            circle(r = inner_r);
            // Remove the top half
            translate([-(outer_r + 1), 0])
                square([2 * (outer_r + 1), outer_r + 1]);
        }
    }
}

module stem_2d() {
    translate([width - stroke_w, 0])
        square([stroke_w, back_height]);
}

module j_2d() {
    union() {
        // Bottom arch
        arch_2d();

        // Gusset: outer back corner only, clipped to outside of inner arc
        difference() {
            hull() {
                // Solid outer quarter-circle (270° to 360°)
                intersection() {
                    translate([outer_r, outer_r]) circle(r = outer_r);
                    translate([outer_r, -1]) square([outer_r + 1, outer_r + 2]);
                }
                polygon([
                    [width - stroke_w, 0],
                    [width,            0],
                    [width,            outer_r],
                    [width - stroke_w, outer_r]
                ]);
            }
            // Clip out the inner cavity
            translate([outer_r, outer_r]) circle(r = inner_r);
        }

        // Rounded end at the left terminus of the arch
        translate([stroke_w / 2, outer_r])
            circle(r = stroke_w / 2);

        // Right stem
        stem_2d();
    }
}

// --- Chamfered extrusion ---
// Minkowski with a bicone produces a true chamfer on all edges
// without convexifying concave profiles the way hull() does.
module chamfer_extrude(h, c) {
    translate([0, 0, c])
        minkowski() {
            linear_extrude(height = h - 2 * c)
                offset(delta = -c) children();
            // Bicone: two cones tip-to-tip, height c each
            union() {
                cylinder(r1 = c, r2 = 0, h = c, $fn = 8);
                mirror([0, 0, 1]) cylinder(r1 = c, r2 = 0, h = c, $fn = 8);
            }
        }
}

// --- 3D extrusion ---
difference() {
    chamfer_extrude(depth, chamfer)
        j_2d();

    // Bolt hole down the center of the back stem
    translate([width - stroke_w / 2, -1, depth / 2])
        rotate([-90, 0, 0])
        cylinder(d = bolt_d, h = back_height + 2);
}
