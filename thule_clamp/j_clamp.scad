// J Clamp Profile
// All dimensions in mm
// --- Parameters ---
back_height = 53+14;  // height of the vertical back stem
inner_d     = 50;     // inside diameter of the J curve
stroke_w    = 18;     // thickness of all strokes
depth       = 38;     // extrusion depth (thickness into Z)
bolt_d      = 9;      // diameter of bolt hole through center of back stem
chamfer     = 2;      // chamfer size on top and bottom outside edges
$fn = 120;

// --- Flange Parameters ---
flange_w      = 40;   // how far the flange extends to the right of the stem
flange_h      = -60;  // height of the vertical leg (negative = downward)
flange_tip_r  = 5;   // radius of the round boss at the far corner of the flange

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
            translate([-(outer_r + 1), 0])
                square([2 * (outer_r + 1), outer_r + 1]);
        }
    }
}

module stem_2d() {
    translate([width - stroke_w, 0])
        square([stroke_w, back_height]);
}

// Triangular flange with round boss at the far corner (opposite the J hook)
module flange_2d() {
    flange_x   = width - stroke_w;  // left edge = right edge of stem
    flange_top = back_height;       // top of stem

    // Three corners of the triangle:
    //   A = top-left  (where stem meets flange top)
    //   B = top-right (far corner, opposite the J — this gets the boss)
    //   C = bottom-left (tip pointing down along the stem)
    ax = flange_x;              ay = flange_top;
    bx = flange_x + flange_w ;  by = flange_top;
    cx = flange_x;              cy = flange_top + flange_h;

    union() {
        polygon([[ax, ay], [bx, by], [cx, cy]]);
        // Round boss at corner B — the far end opposite the J hook
        translate([bx-flange_tip_r, by - flange_tip_r/2 + 2])
            circle(r = flange_tip_r);
    }
}

module j_2d() {
    union() {
        arch_2d();
        difference() {
            hull() {
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
            translate([outer_r, outer_r]) circle(r = inner_r);
        }
        translate([stroke_w / 2, outer_r])
            circle(r = stroke_w / 2);
        stem_2d();
        flange_2d();
    }
}

// --- Chamfered extrusion ---
module chamfer_extrude(h, c) {
    translate([0, 0, c])
        minkowski() {
            linear_extrude(height = h - 2 * c)
                offset(delta = -c) children();
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
    translate([width - stroke_w / 2, -1, depth / 2])
        rotate([-90, 0, 0])
        cylinder(d = bolt_d, h = back_height + 2);
}