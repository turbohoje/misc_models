// ============================================================
//  Shower Pan 90° Elbow — Hull corner knuckle only
//  Hull is applied only to thin discs at the corner end of
//  each leg, so the legs stay as clean cylinders.
// ============================================================

id       = 89;
od       = 115;
wall     = (od - id) / 2;

leg_z    = 70;
leg_x    = 80;

cone_od_base = od;
cone_od_tip  = 43.18;
cone_id_base = id;
cone_id_tip  = cone_od_tip - 2;
cone_len     = 120;

disc_h   = 1;   // thin disc thickness for hull anchors

$fn = 128;

// Thin disc at top of vertical leg (Z=0 plane)
module vert_disc() {
    cylinder(d = od, h = disc_h);
}

// Thin disc at base of horizontal leg (X=0 plane)
module horiz_disc() {
    rotate([0, 90, 0])
        cylinder(d = od, h = disc_h);
}

difference() {
    union() {
        // Vertical leg — straight cylinder
        translate([0, 0, -leg_z])
            cylinder(d = od, h = leg_z);

        // Horizontal leg — straight cylinder
        rotate([0, 90, 0])
            cylinder(d = od, h = leg_x);

        // Corner knuckle — hull of just the two end discs
        hull() {
            vert_disc();
            horiz_disc();
        }

        // Cone on end of horizontal leg
        rotate([0, 90, 0])
            translate([0, 0, leg_x])
            cylinder(d1 = cone_od_base, d2 = cone_od_tip, h = cone_len);
    }

    // --- BORE ---
    union() {
        // Vertical bore
        translate([0, 0, -(leg_z + 1)])
            cylinder(d = id, h = leg_z + 1);

        // Horizontal bore
        rotate([0, 90, 0])
            translate([0, 0, -1])
            cylinder(d = id, h = leg_x + 1);

        // Corner bore knuckle — hull of bore discs clears the shelf
        hull() {
            cylinder(d = id, h = disc_h);
            rotate([0, 90, 0])
                cylinder(d = id, h = disc_h);
        }

        // Cone bore
        rotate([0, 90, 0])
            translate([0, 0, leg_x])
            cylinder(d1 = cone_id_base, d2 = cone_id_tip, h = cone_len + 1);
    }
    //translate([0,250,0])
    //cube(500, center=true);
}

echo(str("Wall: ", wall, " mm"));
echo(str("Cone tip OD: ", cone_od_tip, " mm (1.7 in)"));
echo(str("Cone tip ID: ", cone_id_tip, " mm"));
