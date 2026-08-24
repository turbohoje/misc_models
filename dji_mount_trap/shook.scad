// ============================================================
//  Long S-hook  (parametric, square stock)
//  Units: millimeters
// ============================================================
// ---- Parameters ----
spine_len       = 50;    // length of the straight middle section
overall_w       = 28;    // total side-to-side width of the finished S
thickness       = 5;     // in-plane bar width (the radial cross-section)
z_depth         = 68;    // extrusion depth in Z
hook_sweep      = 180;   // degrees each end curls; 180 = open C, >180 = closes in
kickstand_len   = 25;    // how far the kickstand sticks out
kickstand_y     = spine_len / 2 + 9;  // where it attaches along the shaft
kickstand_dir   = 1;     // 1 = sticks out +X (right), -1 = -X (left)
kickstand_angle = -15;    // tilt about the junction, degrees (+ = CCW)
$fn             = 120;   // arc smoothness
// ---- Derived ----
th = thickness;
r  = (overall_w - th) / 4;   // centerline radius of each hook
                             // width = 4*r + th  ->  r = (width - th)/4
// inner radius must stay positive or rotate_extrude fails
assert(r - th/2 > 0, "overall_w too small (or thickness too big) for this radius");
// One hook: an arc whose connection point sits at the origin
// and which curls up and to the -X side. Cross-section is th (radial) x z_depth (Z).
module hook() {
    translate([-r, 0, 0])
        rotate_extrude(angle = hook_sweep)
            translate([r - th/2, 0, 0])
                square([th, z_depth]);   // radial width x Z depth
}
module s_hook() {
    union() {
        // straight spine, centered on x = 0, running along Y
        translate([-th/2, -0.01, 0])
            cube([th, spine_len + 0.02, z_depth]);
        // top hook  (opens down-left)
        translate([0, spine_len, 0]) hook();
        // bottom hook (top hook turned 180deg -> opens up-right => S shape)
        rotate([0, 0, 180]) hook();
        // kickstand: full-depth fin, pivoted about where it meets the shaft.
        // Pivot = the shaft face at (±th/2, kickstand_y); root buried th into the
        // shaft so the weld stays solid at any tilt angle.
        translate([kickstand_dir > 0 ? th/2 +.5: -th/2, kickstand_y, 0])
            rotate([0, 0, (kickstand_dir > 0 ? 0 : 180) + kickstand_angle])
                translate([-th, -th/2, 0])
                    cube([kickstand_len + th, th, z_depth]);
    }
}
s_hook();