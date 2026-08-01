// ============================================================
// Parametrized Trapezoid (Minkowski-rounded)
// ============================================================
// A trapezoid has two parallel sides (bottom and top) of
// different lengths, separated by a height. This module builds
// the 2D profile, extrudes it, then rounds every edge/corner
// with a Minkowski sum against a sphere.

// ---------- Parameters ----------
bottom_width = 30;   // length of the bottom parallel side
top_width    = 25;   // length of the top parallel side
height       = 10;   // perpendicular distance between the two sides
thickness    = 70;   // extrusion depth (set 0 for a flat 2D shape)
top_offset   = 0;    // horizontal shift of the top side.
                     //   0        = symmetric (isosceles) trapezoid
                     //   any value = fully asymmetric

center_x = true;     // center the shape on the X axis

// ---------- Rounding ----------
round_radius = 2;    // Minkowski sphere radius (0 = sharp edges)
sphere_fn    = 24;   // facets on the rounding sphere (higher = smoother, slower)

// ---------- Module: flat 2D profile ----------
module trapezoid(bottom, top, h, offset = 0, center = true) {
    bl = [0, 0];
    br = [bottom, 0];
    top_start = (bottom - top) / 2 + offset;
    tl = [top_start,       h];
    tr = [top_start + top, h];
    dx = center ? -bottom / 2 : 0;
    translate([dx, 0])
        polygon(points = [bl, br, tr, tl]);
}

// ---------- Module: rounded solid ----------
module trapezoid_solid(bottom, top, h, thick, offset, center, r, sfn) {
    if (r > 0 && thick > 2 * r) {
        // Inset the profile by r and shorten the extrusion by 2r so the
        // Minkowski sphere grows the shape back to its nominal size.
        translate([0, 0, r])
            minkowski() {
                linear_extrude(height = thick - 2 * r)
                    offset(r = -r)
                        trapezoid(bottom, top, h, offset, center);
                sphere(r = r, $fn = sfn);
            }
    } else {
        // No rounding (or radius too large for the geometry): plain extrude.
        linear_extrude(height = thick)
            trapezoid(bottom, top, h, offset, center);
    }
}

// ---------- Build ----------
if (thickness > 0) {
    trapezoid_solid(bottom_width, top_width, height, thickness,
                    top_offset, center_x, round_radius, sphere_fn);
} else {
    // Flat 2D: round the profile outline only.
    offset(r = round_radius)
        offset(r = -round_radius)
            trapezoid(bottom_width, top_width, height, top_offset, center_x);
}