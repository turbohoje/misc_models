// ===========================================
// Parameterized Dowel Center
// ===========================================
// The cylinder diameter is the main parameter —
// set it to match your dowel hole size.

/* [Main Parameters] */
// Diameter of the cylinder that fits into the hole
cylinder_diameter = 12;    // [4:0.5:20]

/* [Proportional Overrides] */
// Set to 0 to use auto-calculated proportional values,
// or enter a positive number to override.

// Height of the cylinder body
cylinder_height_override = 0;   // [0:0.5:20]

// Outer diameter of the flange/rim
flange_diameter_override = 0;   // [0:0.5:30]

// Thickness of the flange
flange_thickness_override = 0;  // [0:0.25:5]

// Height of the conical point
point_height_override = 0;      // [0:0.5:15]

// Diameter of the point base
point_base_diameter_override = 0; // [0:0.5:15]

/* [Quality] */
$fn = 80;

// --- Derived dimensions (proportional to cylinder diameter) ---
cylinder_radius = cylinder_diameter / 2;

cylinder_height = (cylinder_height_override > 0)
    ? cylinder_height_override
    : cylinder_diameter * 0.75;

flange_diameter = (flange_diameter_override > 0)
    ? flange_diameter_override
    : cylinder_diameter * 1.5;

flange_thickness = (flange_thickness_override > 0)
    ? flange_thickness_override
    : cylinder_diameter * 0.15;

point_height = (point_height_override > 0)
    ? point_height_override
    : cylinder_diameter * 0.5;

point_base_diameter = (point_base_diameter_override > 0)
    ? point_base_diameter_override
    : cylinder_diameter * 0.6;

// --- Small chamfer on cylinder bottom edge ---
chamfer = cylinder_diameter * 0.05;

// --- Assembly ---
module dowel_center() {
    // Cylinder body
    union() {
        // Main cylinder with small bottom chamfer for easy insertion
        translate([0, 0, chamfer])
            cylinder(h = cylinder_height - chamfer, r = cylinder_radius);

        // Chamfered entry ring
        cylinder(h = chamfer, r1 = cylinder_radius - chamfer, r2 = cylinder_radius);
    }

    // Flange / rim sitting on top of the cylinder
    translate([0, 0, cylinder_height])
        cylinder(h = flange_thickness, r = flange_diameter / 2);

    // Conical point on top of the flange
    translate([0, 0, cylinder_height + flange_thickness])
        cylinder(h = point_height, r1 = point_base_diameter / 2, r2 = 0);
}

dowel_center();

// --- Info echo ---
echo(str("Cylinder: ø", cylinder_diameter, " × ", cylinder_height, "mm"));
echo(str("Flange:   ø", flange_diameter, " × ", flange_thickness, "mm"));
echo(str("Point:    ø", point_base_diameter, " base, ", point_height, "mm tall"));