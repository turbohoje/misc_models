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

// --- Flange Parameters ---
flange_w    = 40;     // how far the flange extends to the right of the stem
flange_h    = -60;     // height of the vertical leg of the flange triangle

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

// Triangular flange: right triangle sitting on top of the stem
// Vertical leg along the right edge of the stem, hypotenuse slopes up-right
module flange_2d() {
    flange_x = width - stroke_w;  // left edge of stem / left edge of flange
    flange_top = back_height;     // base y (top of stem)

    polygon([
        [flange_x,              flange_top],
        [flange_x + flange_w,   flange_top],
        [flange_x,              flange_top + flange_h]
    ]);
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
        flange_2d();  // <-- added here
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