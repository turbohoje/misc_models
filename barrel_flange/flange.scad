// Parameterized Barrel Flange
// All dimensions in mm

/* [Main Flange] */
inner_bore_d  = 147.32;  // diameter of center bore
outer_d       = 191.52;  // outer diameter of flange disc
thickness     =   6.35;  // thickness of flat flange ring

/* [Hub] */
hub_od        = 149.86;  // outer diameter of raised hub ring around bore
hub_height    =  25.40;  // hub height above flange face (set to 0 to omit)

/* [Bolt Holes] */
num_holes     = 8;       // number of bolt holes
hole_d        =  4.83;   // bolt hole diameter
bolt_circle_d = 0;       // bolt hole circle diameter; 0 = auto (midpoint of hub OD and outer OD)
hole_rotation = 22.5;    // rotate entire hole pattern (degrees)

/* [Countersink] */
countersink_d = 9.66;    // countersink diameter at bottom face (0 to disable); 45° cone auto-depths

/* [Chamfer] */
bore_chamfer  = 4.00;    // chamfer size on inner bore edge at bottom face (0 to disable)
outer_chamfer = 4.00;    // chamfer size on outer flange edge at bottom face (0 to disable)

$fn = 128;

_bolt_circle_d = (bolt_circle_d > 0) ? bolt_circle_d : (hub_od + outer_d) / 2;
_cs_depth = (countersink_d - hole_d) / 2;  // 45° half-angle: depth == delta radius

difference() {
    union() {
        cylinder(d = outer_d, h = thickness);
        if (hub_height > 0)
            cylinder(d = hub_od, h = thickness + hub_height);
    }
    // center bore
    translate([0, 0, -1])
        cylinder(d = inner_bore_d, h = thickness + hub_height + 2);
    // 45° chamfer on inner bore edge at bottom face
    if (bore_chamfer > 0)
        translate([0, 0, -0.01])
            cylinder(h = bore_chamfer + 0.01, r1 = inner_bore_d / 2 + bore_chamfer, r2 = inner_bore_d / 2);
    // 45° chamfer on outer flange edge at bottom face — cylinder with cone removed, used as cutting tool
    if (outer_chamfer > 0)
        translate([0, 0, -0.01])
            difference() {
                cylinder(h = outer_chamfer + 0.01, r = outer_d / 2 + 0.01);
                cylinder(h = outer_chamfer + 0.02, r1 = outer_d / 2 - outer_chamfer, r2 = outer_d / 2 + 0.01);
            }
    // bolt holes + countersinks
    for (i = [0 : num_holes - 1]) {
        angle = hole_rotation + i * 360 / num_holes;
        translate([cos(angle) * _bolt_circle_d / 2,
                   sin(angle) * _bolt_circle_d / 2,
                   0]) {
            // through hole
            translate([0, 0, -1])
                cylinder(d = hole_d, h = thickness + 2);
            // 45° countersink cone on bottom face
            if (countersink_d > 0)
                translate([0, 0, -0.01])
                    cylinder(h = _cs_depth + 0.01, r1 = countersink_d / 2, r2 = hole_d / 2);
        }
    }
}
