"""
Generate DXF for jerry can mounting plate v9 (SendCutSend ready).

v9 adds to v7:
  - 11× Ø12.7mm (½") utility holes around the perimeter for tie straps,
    bungees, zip ties. 15mm inset from edge.
  - 5× lightening cutouts: 2× Ø130mm circles centered in each can mount
    pattern, 2× Ø80mm circles in the upper inboard area between SCAD and
    can mounts, and 1× 400×90mm stadium/pill below the SCAD circle.

v9 distinctions from v8 (intermediate):
  - The top-edge utility hole was moved from a single center hole (which
    sat above the SCAD object and would interfere with strap use) to TWO
    holes flanking the SCAD circle at x = ±90mm. This puts both holes on
    material that is clear of the SCAD object behind the plate.

Plate shape (unchanged from v7):
  Hexagonal polygon with 3 bend lines (2 angled shoulders + 1 horizontal
  bottom), all folding toward the cans. All outline corners rounded.

Coordinate system: SCAD circle center at (0, 0). All dimensions in mm.

Layers:
  - CUT: outer polygon, all holes, all lightening cutouts
  - BEND: bend lines (red layer; SCS recognizes these)
"""

import ezdxf
import math
import os

doc = ezdxf.new('R2010', setup=True)
msp = doc.modelspace()

# Layers
doc.layers.add('CUT', color=7)
doc.layers.add('BEND', color=1)

# ==============================================================
# === Design parameters                                       ===
# ==============================================================

# SCAD object reference
SCAD_RADIUS = 114.3

# Clearance constraints
H_TANGENT_CLEAR = 110.0
CAN_TO_SCAD_TOP_MAX = 152.4

# Jerry can mount pattern
CAN_PATTERN_W = 163.0
CAN_PATTERN_H = 125.0
CAN_HOLE_DIAM = 8.0
CAN_HEIGHT = 457.0
CAN_BOTTOM_OFFSET = 2.0

# Bend / flange geometry
FLANGE_W = 20.0
BOTTOM_HOLE_TO_BEND = 50.0

# Lug holes
LUG_DIAM = 12.7
LUGS = [
    (0.0,    71.6),   # single, top
    (-33.6, -46.2),   # pair, bottom-left
    ( 33.6, -46.2),   # pair, bottom-right
]

# Top section
TOP_SECTION_HALFWIDTH = 140.0
TOP_EDGE_Y = +130.0

# Corner radii
TOP_CORNER_R = 10.0
SHOULDER_CORNER_R = 15.0
BOTTOM_CORNER_R = 10.0

# Utility holes
UTIL_HOLE_DIAM = 12.7         # ½"
UTIL_EDGE_INSET = 15.0        # mm from outline edge to hole center

# Lightening cutouts
BIG_CIRCLE_DIAM = 130.0       # Ø130mm in each can pattern center
SMALL_CIRCLE_DIAM = 95.0      # Ø95mm in upper inboard area (was 80mm)
SMALL_CIRCLE_CENTER = (180.0, -10.0)  # ±x, y (was +20, lowered for bend clearance)
PILL_LENGTH = 400.0
PILL_WIDTH = 90.0
PILL_CENTER_Y = -180.0

# ==============================================================
# === Derived geometry                                        ===
# ==============================================================

bottom_hole_y = SCAD_RADIUS + CAN_TO_SCAD_TOP_MAX - CAN_HEIGHT - CAN_BOTTOM_OFFSET
top_hole_y = bottom_hole_y + CAN_PATTERN_H
bottom_bend_y = bottom_hole_y - BOTTOM_HOLE_TO_BEND
plate_bottom_y = bottom_bend_y - FLANGE_W

inboard_hole_x = SCAD_RADIUS + H_TANGENT_CLEAR
outboard_hole_x = inboard_hole_x + CAN_PATTERN_W

EDGE_MARGIN = 25.0
plate_side_x = outboard_hole_x + EDGE_MARGIN

side_panel_top_y = top_hole_y + 22.0

shoulder_dx = plate_side_x - TOP_SECTION_HALFWIDTH
shoulder_dy = side_panel_top_y - TOP_EDGE_Y
shoulder_len = math.hypot(shoulder_dx, shoulder_dy)
shoulder_angle_deg = math.degrees(math.atan2(-shoulder_dy, shoulder_dx))

shoulder_dir = (shoulder_dx / shoulder_len, shoulder_dy / shoulder_len)
right_shoulder_inward = (shoulder_dir[1], -shoulder_dir[0])

# Sanity-check inward normal direction
mid_x = (TOP_SECTION_HALFWIDTH + plate_side_x) / 2
mid_y = (TOP_EDGE_Y + side_panel_top_y) / 2
to_origin_unit = (-mid_x / math.hypot(mid_x, mid_y), -mid_y / math.hypot(mid_x, mid_y))
dot = right_shoulder_inward[0]*to_origin_unit[0] + right_shoulder_inward[1]*to_origin_unit[1]
assert dot > 0, f"Inward normal direction wrong! dot={dot}"

# Bend line endpoints
right_bend_top = (
    TOP_SECTION_HALFWIDTH + FLANGE_W * right_shoulder_inward[0],
    TOP_EDGE_Y + FLANGE_W * right_shoulder_inward[1],
)
right_bend_bot = (
    plate_side_x + FLANGE_W * right_shoulder_inward[0],
    side_panel_top_y + FLANGE_W * right_shoulder_inward[1],
)
left_bend_top = (-right_bend_top[0], right_bend_top[1])
left_bend_bot = (-right_bend_bot[0], right_bend_bot[1])

# ==============================================================
# === Outline polygon with rounded corners                    ===
# ==============================================================

THW = TOP_SECTION_HALFWIDTH

sharp_vertices = [
    (-THW, TOP_EDGE_Y),
    ( THW, TOP_EDGE_Y),
    ( plate_side_x, side_panel_top_y),
    ( plate_side_x, plate_bottom_y),
    (-plate_side_x, plate_bottom_y),
    (-plate_side_x, side_panel_top_y),
]
fillet_radii = [TOP_CORNER_R, TOP_CORNER_R, SHOULDER_CORNER_R, BOTTOM_CORNER_R, BOTTOM_CORNER_R, SHOULDER_CORNER_R]


def fillet_polygon_vertex(prev_pt, curr_pt, next_pt, radius):
    v_in = (prev_pt[0] - curr_pt[0], prev_pt[1] - curr_pt[1])
    v_out = (next_pt[0] - curr_pt[0], next_pt[1] - curr_pt[1])
    len_in = math.hypot(*v_in)
    len_out = math.hypot(*v_out)
    u_in = (v_in[0] / len_in, v_in[1] / len_in)
    u_out = (v_out[0] / len_out, v_out[1] / len_out)
    cos_theta = max(-1.0, min(1.0, u_in[0]*u_out[0] + u_in[1]*u_out[1]))
    theta = math.acos(cos_theta)
    t = radius / math.tan(theta / 2)
    tan_in = (curr_pt[0] + t * u_in[0], curr_pt[1] + t * u_in[1])
    tan_out = (curr_pt[0] + t * u_out[0], curr_pt[1] + t * u_out[1])
    bulge_mag = math.tan((math.pi - theta) / 4)
    forward_in = (-u_in[0], -u_in[1])
    cross = forward_in[0] * u_out[1] - forward_in[1] * u_out[0]
    return tan_in, tan_out, (1 if cross > 0 else -1) * bulge_mag


n = len(sharp_vertices)
polyline_verts = []
for i in range(n):
    prev_pt = sharp_vertices[(i - 1) % n]
    curr_pt = sharp_vertices[i]
    next_pt = sharp_vertices[(i + 1) % n]
    r = fillet_radii[i]
    tan_in, tan_out, bulge = fillet_polygon_vertex(prev_pt, curr_pt, next_pt, r)
    polyline_verts.append((tan_in[0], tan_in[1], bulge))
    polyline_verts.append((tan_out[0], tan_out[1], 0))

ezdxf_verts = [(v[0], v[1], 0, 0, v[2]) for v in polyline_verts]
msp.add_lwpolyline(ezdxf_verts, format='xyseb', close=True, dxfattribs={'layer': 'CUT'})

# ==============================================================
# === Lug holes ===
# ==============================================================
for x, y in LUGS:
    msp.add_circle((x, y), LUG_DIAM/2, dxfattribs={'layer': 'CUT'})

# ==============================================================
# === Jerry can mount holes ===
# ==============================================================
CAN_HOLES = []
for x_sign in (-1, 1):
    for x_abs in (inboard_hole_x, outboard_hole_x):
        for y in (bottom_hole_y, top_hole_y):
            CAN_HOLES.append((x_sign * x_abs, y))

for x, y in CAN_HOLES:
    msp.add_circle((x, y), CAN_HOLE_DIAM/2, dxfattribs={'layer': 'CUT'})

# ==============================================================
# === Perimeter utility holes (11)                            ===
# ==============================================================
# Layout:
#   - 2 on top edge (flanking SCAD circle): x = ±90, y = +130 - 15 = +115
#   - 1 at midpoint of each shoulder (×2), inset 15mm perpendicular
#   - 1 at midpoint of each side panel (×2): x = ±(412.3 - 15) = ±397.3, y = midpoint
#   - 5 on bottom edge evenly spaced

util_holes = []

# Top: 2 holes at x = ±90, y = TOP_EDGE_Y - UTIL_EDGE_INSET
util_holes.append((-90.0, TOP_EDGE_Y - UTIL_EDGE_INSET))
util_holes.append((+90.0, TOP_EDGE_Y - UTIL_EDGE_INSET))

# Shoulders (midpoints, inset 15mm perpendicular inward)
right_shoulder_mid = (
    (TOP_SECTION_HALFWIDTH + plate_side_x) / 2,
    (TOP_EDGE_Y + side_panel_top_y) / 2,
)
right_shoulder_util = (
    right_shoulder_mid[0] + UTIL_EDGE_INSET * right_shoulder_inward[0],
    right_shoulder_mid[1] + UTIL_EDGE_INSET * right_shoulder_inward[1],
)
left_shoulder_util = (-right_shoulder_util[0], right_shoulder_util[1])
util_holes.append(right_shoulder_util)
util_holes.append(left_shoulder_util)

# Side panels (midpoints): right at (plate_side_x - 15, mid), left mirror
side_mid_y = (side_panel_top_y + plate_bottom_y) / 2
util_holes.append(( plate_side_x - UTIL_EDGE_INSET, side_mid_y))
util_holes.append((-plate_side_x + UTIL_EDGE_INSET, side_mid_y))

# Bottom edge: 5 holes evenly distributed (6 equal segments along 824.6mm)
# Spacing 824.6 / 6 = 137.4mm. Hole x positions at multiples of 137.4 from left edge.
# Holes at fractions 1/6, 2/6, 3/6, 4/6, 5/6 of the bottom edge length:
# x = -plate_side_x + 137.4 * k for k = 1..5
bottom_y = plate_bottom_y + UTIL_EDGE_INSET
for k in range(1, 6):
    x = -plate_side_x + (2 * plate_side_x) * k / 6
    util_holes.append((x, bottom_y))

for x, y in util_holes:
    msp.add_circle((x, y), UTIL_HOLE_DIAM/2, dxfattribs={'layer': 'CUT'})

# ==============================================================
# === Lightening cutouts                                      ===
# ==============================================================

# Two Ø130mm circles centered in each can-mount pattern
big_circle_centers = [
    (-(inboard_hole_x + outboard_hole_x)/2, (top_hole_y + bottom_hole_y)/2),  # left can center
    ( (inboard_hole_x + outboard_hole_x)/2, (top_hole_y + bottom_hole_y)/2),  # right can center
]
for cx, cy in big_circle_centers:
    msp.add_circle((cx, cy), BIG_CIRCLE_DIAM/2, dxfattribs={'layer': 'CUT'})

# Two Ø80mm circles in the upper inboard area at (±180, +20)
small_circle_centers = [
    (-SMALL_CIRCLE_CENTER[0], SMALL_CIRCLE_CENTER[1]),
    ( SMALL_CIRCLE_CENTER[0], SMALL_CIRCLE_CENTER[1]),
]
for cx, cy in small_circle_centers:
    msp.add_circle((cx, cy), SMALL_CIRCLE_DIAM/2, dxfattribs={'layer': 'CUT'})

# Bottom pill (stadium): length PILL_LENGTH, width PILL_WIDTH, centered at (0, PILL_CENTER_Y)
# Rectangular section from x=-L/2+W/2 to x=+L/2-W/2 (W/2 = cap radius), plus two semicircular caps.
# Build as a closed polyline with two arc segments (bulge = 1 for semicircle).
cap_r = PILL_WIDTH / 2
rect_half_len = PILL_LENGTH/2 - cap_r  # x extent of the straight rectangular section
pill_y_top = PILL_CENTER_Y + cap_r
pill_y_bot = PILL_CENTER_Y - cap_r
# Polyline traversal (counter-clockwise to give positive interior):
# Start at top-right of rect section, go LEFT along top, then arc DOWN around left cap (CCW),
# then RIGHT along bottom, then arc UP around right cap (CCW), back to start.
# Bulge for 180° CCW arc = tan(45°) = 1.0
pill_verts = [
    (+rect_half_len, pill_y_top, 0),   # top-right
    (-rect_half_len, pill_y_top, 1.0),  # top-left, then bulge 1 (semicircle CCW down to bottom-left)
    (-rect_half_len, pill_y_bot, 0),   # bottom-left
    (+rect_half_len, pill_y_bot, 1.0),  # bottom-right, bulge 1 (semicircle CCW up to top-right)
]
pill_ezdxf = [(v[0], v[1], 0, 0, v[2]) for v in pill_verts]
msp.add_lwpolyline(pill_ezdxf, format='xyseb', close=True, dxfattribs={'layer': 'CUT'})

# ==============================================================
# === Bend lines on BEND layer                                ===
# ==============================================================
msp.add_line(right_bend_top, right_bend_bot, dxfattribs={'layer': 'BEND'})
msp.add_line(left_bend_top, left_bend_bot, dxfattribs={'layer': 'BEND'})
bottom_bend_x_max = plate_side_x - 2.0
msp.add_line(
    (-bottom_bend_x_max, bottom_bend_y),
    ( bottom_bend_x_max, bottom_bend_y),
    dxfattribs={'layer': 'BEND'}
)

# ==============================================================
# === Save + summarize                                        ===
# ==============================================================
output_path = '/mnt/user-data/outputs/jerry_can_plate.dxf'
os.makedirs('/mnt/user-data/outputs', exist_ok=True)
doc.saveas(output_path)

print(f"Saved: {output_path}")
print()
print("=== Plate v9 — hexagonal, utility holes, lightening cutouts ===")
print(f"Material: 3/16\" (4.76mm) 304 stainless steel")
print(f"Plate envelope: {2*plate_side_x:.1f}mm × {TOP_EDGE_Y - plate_bottom_y:.1f}mm")
print(f"Shoulder angle: {shoulder_angle_deg:.1f}°  ·  Flange width: {FLANGE_W}mm")
print()
print(f"Lug holes (Ø{LUG_DIAM}mm): {len(LUGS)}")
print(f"Jerry can holes (Ø{CAN_HOLE_DIAM}mm): {len(CAN_HOLES)}")
print(f"Utility holes (Ø{UTIL_HOLE_DIAM}mm): {len(util_holes)}")
for x, y in util_holes:
    print(f"  ({x:+7.1f}, {y:+7.1f})")
print()
print("Lightening cutouts:")
print(f"  2× Ø{BIG_CIRCLE_DIAM}mm circles at can pattern centers: (±{big_circle_centers[1][0]:.1f}, {big_circle_centers[1][1]:.1f})")
print(f"  2× Ø{SMALL_CIRCLE_DIAM}mm circles in upper inboard: (±{SMALL_CIRCLE_CENTER[0]:.1f}, +{SMALL_CIRCLE_CENTER[1]:.1f})")
print(f"  1× pill {PILL_LENGTH}×{PILL_WIDTH}mm centered at (0, {PILL_CENTER_Y:.1f})")
print()

# Material removed estimate
big_area = 2 * math.pi * (BIG_CIRCLE_DIAM/2)**2
small_area = 2 * math.pi * (SMALL_CIRCLE_DIAM/2)**2
pill_area = (PILL_LENGTH - PILL_WIDTH) * PILL_WIDTH + math.pi * (PILL_WIDTH/2)**2
util_area = 11 * math.pi * (UTIL_HOLE_DIAM/2)**2
total_area = big_area + small_area + pill_area + util_area
total_kg = total_area * 1e-6 * FLANGE_W * 0  # not flange — full plate area
# Wait, area removed × material thickness × density
thickness_mm = 4.76
density_g_per_cm3 = 7.85
mass_g = total_area * 1e-2 * thickness_mm * 1e-1 * density_g_per_cm3  # mm² × mm = mm³; / 1000 = cm³
# Actually: total_area [mm²] × thickness_mm [mm] = volume_mm³. /1000 → cm³. × 7.85 g/cm³ = g.
mass_g = total_area * thickness_mm / 1000 * density_g_per_cm3
print(f"Material removed by cutouts + utility holes:")
print(f"  Total area: {total_area:.0f} mm² = {total_area/100:.1f} cm²")
print(f"  Mass saved: {mass_g:.0f} g = {mass_g * 0.00220462:.2f} lb")
print()
print("Bend lines:")
print(f"  Right shoulder: ({right_bend_top[0]:+7.1f}, {right_bend_top[1]:+7.1f}) → "
      f"({right_bend_bot[0]:+7.1f}, {right_bend_bot[1]:+7.1f})")
print(f"  Left shoulder:  mirror of right")
print(f"  Bottom: y = {bottom_bend_y}, full width")
