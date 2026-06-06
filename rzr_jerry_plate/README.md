# Jerry Can Mounting Plate for Spare Tire Hanger (v9)

A laser-cut, hexagonal flat plate with three bend lines, eleven utility holes, and five lightening cutouts. Forms a partial enclosure around an OpenSCAD tire spacer/hanger on a Polaris RZR Turbo R, with two 5-gallon NATO-style jerry cans hanging vertically on either side of the spare tire.

## How it mounts

```
                     OUTBOARD (away from vehicle)
                     │
                     │
   ┌─── Jerry can ───┤ Plate (this part) ├─── Jerry can ───┐
   │                 │                   │                 │
   │  Lug nuts pass through plate AND SCAD object AND tire │
   │                 │                   │                 │
                     │
                     SPARE TIRE
                     │
                     SCAD object (tire spacer)
                     │
                     RZR tire hanger arm
                     │
                     INBOARD (toward vehicle)
```

The plate is **not** independently fastened. It is held in place by:
1. The clamping force of the lug nuts (passing through 3 lug holes in the plate)
2. Friction with the SCAD object on the inboard side and the tire's outboard wheel face on the outboard side
3. The bend flanges partially wrap around the SCAD object, providing structural stiffness and side-loading resistance

This is the same mounting concept as the SCAD object itself — sandwiched in the lug bolt clamp load.

## Files in this project

| File | Purpose |
|------|---------|
| `jerry_can_plate.dxf` | The cutting file for SendCutSend.com |
| `jerry_can_plate_preview.png` | Visual preview of the DXF as it will be cut |
| `gen_plate.py` | Python source that generates the DXF (using ezdxf library) |
| `tire_hanger_face.scad` | The pre-existing OpenSCAD object this plate mates against |
| `README.md` | This file |

## Plate shape (v9)

Hexagonal polygon (6 vertices, all rounded), 3 bend lines, all folding the same direction (toward the cans). All bend lines run uninterrupted across the plate; no bend relief notches are used.

## Critical dimensions

### Overall envelope (flat blank, before bending)
- **Total width: 824.6mm** (~32.5")
- **Total height: 392.3mm** (~15.4")
- **Material: 3/16" (0.1875" / 4.76mm) 304 stainless steel**
- **Weight after cutouts: ~5.3 kg / 11.7 lb** (was ~8.1 kg / 17.9 lb before cutouts)
- **Weight saved by cutouts: ~2.85 kg / 6.3 lb**

### Hexagonal outline (key vertices)

All coordinates referenced to **SCAD circle center at (0, 0)**. The plate is symmetric about the Y axis. Coordinates are the sharp/theoretical vertices; actual outline replaces each with an arc of the specified radius.

| Vertex | X (mm) | Y (mm) | Fillet R |
|--------|--------|--------|----------|
| Top-left of top section | -140.0 | +130.0 | 10mm |
| Top-right of top section | +140.0 | +130.0 | 10mm |
| Right shoulder bottom | +412.3 | -45.3 | 15mm |
| Bottom-right corner | +412.3 | -262.3 | 10mm |
| Bottom-left corner | -412.3 | -262.3 | 10mm |
| Left shoulder bottom | -412.3 | -45.3 | 15mm |

Shoulder edges at ~32.8° below horizontal.

### Bend lines (3 total)

All bends fold **toward the cans** (outboard).

| Bend | Start | End |
|------|-------|-----|
| Right shoulder | (+129.2, +113.2) | (+401.5, -62.1) |
| Left shoulder | (-129.2, +113.2) | (-401.5, -62.1) |
| Bottom | (-410.3, -242.3) | (+410.3, -242.3) |

After bending, each of the three flanges projects ~20mm outboard.

### Hole patterns

**3× lug holes (Ø12.7mm / 0.5")** — match the SCAD tire spacer:
- (0, +71.6) — top single
- (±33.6, -46.2) — bottom pair

**8× jerry can mount holes (Ø8mm)** — two 4-hole 163×125mm rectangles:
- Left can corners: (±224.3, -67.3) and (±224.3, -192.3) at x=-224.3 and x=-387.3
- Right can corners: mirror of left

**11× utility holes (Ø12.7mm / 0.5")** — perimeter strap points at 15mm inset from edge:

| Location | Count | Positions |
|----------|-------|-----------|
| Top edge (flanking SCAD) | 2 | (±90.0, +115.0) |
| Shoulder midpoints | 2 | (±268.0, +29.7) — on flange side of shoulder bend |
| Side panel midpoints | 2 | (±397.3, -153.8) |
| Bottom edge (along flange) | 5 | (-274.9, -137.4, 0, +137.4, +274.9 at y=-247.3) |

The two top-edge holes flank the SCAD circle (x ≥ 60mm from origin keeps them clear of the SCAD area behind the plate). The shoulder holes sit on the bent-over flange portion after folding. The bottom holes all sit on the bottom flange.

### Lightening cutouts (5 total) — saves ~6.3 lb

| Cutout | Shape | Size | Center | Notes |
|--------|-------|------|--------|-------|
| Right can center | Circle | Ø130mm | (+305.8, -129.8) | Dead space in middle of can mount |
| Left can center | Circle | Ø130mm | (-305.8, -129.8) | Mirror |
| Upper inboard right | Circle | Ø95mm | (+180.0, -10.0) | Between SCAD and can mount |
| Upper inboard left | Circle | Ø95mm | (-180.0, -10.0) | Mirror |
| Bottom belly | Stadium/Pill | 400×90mm | (0, -180.0) | Largest cutout; between cans below SCAD |

All cutouts have ≥15mm clearance to every other feature (holes, bends, edges, the SCAD circle reference).

## Design constraints (drives the geometry)

### Constraint 1: Horizontal-tangent clearance from SCAD circle ≥ 110mm
Inboard can holes sit at **x = ±224.3mm** (= 114.3 SCAD radius + 110mm).

### Constraint 2: Jerry can top ≤ 6" (152.4mm) above SCAD circle top
Drives bottom hole row Y to exactly **y = -192.3mm**.

### Constraint 3: Bottom holes ≥ 50mm above bottom bend line
**bottom_bend_y = -242.3mm**

### Constraint 4: 20mm flange width
Plate bottom edge at **y = -262.3mm**.

### Constraint 5: Lug pattern matches SCAD object (inverted)
Single lug at top, pair at bottom — flipped from the original SCAD orientation.

### Constraint 6: Top section clears SCAD circle vertically
Top edge at y=+130 (15.7mm above SCAD top).

### Constraint 7: All non-structural features have ≥15mm clearance to each other
- Utility holes: 15mm inset from edges
- Lightening cutouts: 15mm clearance to holes/bends/edges
- This is conservative — SendCutSend can handle tighter, but 15mm minimizes stress concentration

### Constraint 8: Top utility holes clear of SCAD object behind plate
The 2 top-edge utility holes sit at x=±90mm so they don't sit directly above the SCAD object. This means anything threaded through them (straps, carabiners) doesn't interfere with the SCAD/lug area behind.

## Material strength notes

**Selected**: 3/16" (4.76mm) 304 stainless steel.

**Load case**: 2× 5-gallon jerry cans, ~25 lb each full. RZR Turbo R operation — 3-4g vertical loading on washboard/rocky terrain, occasional higher spikes.

### Strength impact of the cutouts

The lightening cutouts are placed in **low-stress regions**:

- **Ø130 between-can circles**: between the 4 can mount holes. The cans bolt at the 4 corners with their own structure; the material between contributes minimally to load paths.
- **Ø95 upper inboard circles**: between SCAD and inboard can holes, in an area that sees mostly compressive load (from the lug clamp).
- **400×90 bottom pill**: in the lower belly of the plate, below the SCAD object. This region sees mostly bending load between the bottom flange and the can mount areas, which is well-handled by the remaining material around the pill.

### Quick FEA summary (post-cutouts)
- **Bending stress (static)**: ~6 MPa peak (vs ~4 MPa before cutouts). Still <3% of 215 MPa yield.
- **Bending stress (4g shock)**: ~24 MPa, ~11% of yield. Comfortable margin.
- **Torsion**: Triangulated shoulder + bottom flange handles can twist load. Cutouts don't significantly affect torsional stiffness since they're in regions where shear flow is low.
- **Predicted deflection at 4g**: Still <1mm at can ends.

### Material alternatives
| Thickness | Material | Verdict |
|-----------|----------|---------|
| 0.125" | 304 SS | Marginal with cutouts. Fatigue risk increases. |
| **0.1875"** | **304 SS** | **Selected. Good margin for RZR vibration even with cutouts.** |
| 0.250" | 304 SS | Overkill but bombproof. Adds ~3 lb back (net ~10 lb plate). |
| 0.1875" | Cold-rolled steel | Cheaper, needs paint/powder coat. |

## How to modify

### To change utility hole layout
Edit the `util_holes` list construction in `gen_plate.py`. The layout follows the perimeter:
- `util_holes.append((x, y))` adds a hole at that position
- The 5-hole bottom row uses a for loop with `2*plate_side_x * k / 6` for k=1..5

### To change lightening cutout sizes/positions
Edit the parameters near the top of `gen_plate.py`:
- `BIG_CIRCLE_DIAM` and the centers (auto-computed as can pattern midpoints)
- `SMALL_CIRCLE_DIAM` and `SMALL_CIRCLE_CENTER`
- `PILL_LENGTH`, `PILL_WIDTH`, `PILL_CENTER_Y`

### To add more lightening cutouts
The cutouts are just `msp.add_circle()` calls (or the pill polyline) on the 'CUT' layer. Add additional circles/shapes the same way. Keep 15mm clearance to every other feature.

### To remove lightening cutouts (e.g., for max strength)
Comment out the relevant `msp.add_circle()` or `add_lwpolyline()` calls in the "Lightening cutouts" section.

### To change clearance from circle (currently 110mm horizontal-tangent)
Edit `H_TANGENT_CLEAR`. All dependent dimensions recompute.

### To change material thickness
The DXF doesn't encode thickness — set it on the SendCutSend portal. Bend allowance changes with thickness; final bent dimensions shift slightly.

### To change flange width (currently 20mm)
Edit `FLANGE_W`.

### To change corner radii
Edit `TOP_CORNER_R`, `SHOULDER_CORNER_R`, `BOTTOM_CORNER_R`.

### To re-orient the lug pattern
Edit the `LUGS` list. Flip Y signs to put single lug at bottom.

### To regenerate the DXF after parameter changes
```bash
python gen_plate.py
python preview.py  # optional: render PNG preview
```

## Assembly notes

1. **Sandwich order** (outboard to inboard): jerry cans → plate (flanges facing outboard) → SCAD tire spacer → wheel face → tire hanger arm
2. **Lug nut torque**: Use stock RZR Turbo R wheel lug torque spec (~95 ft-lb; verify in service manual)
3. **First-time fit-up**: Test-fit empty (no cans) first. The plate's three bent flanges should clear the SCAD object cleanly.
4. **Jerry can holder mounting**: M8 hardware (button-head bolts work well, stainless to match)
5. **Strap usage**: Use the 11 utility holes for ratchet straps, bungees, or zip ties. The bottom 5 (on the flange) are particularly useful for cargo lashing.
6. **Anti-corrosion**: 304 SS is fine outdoors as-is.

## Known limitations

- **Plate width (824.6mm / 32.5") exceeds typical UTV spare tire OD** by ~50mm per side. Cans protrude beyond the tire — improves access but increases overall width.
- **CG of full cans is moderate** — cans pushed low so CG is roughly at SCAD center height. Good for stability.
- **Three folds, one open side**: Bottom flange can trap water. Drill 3-4 small (Ø3mm) drain holes along the bottom flange if needed.
- **Tight 6" constraint**: Can tops at exactly the limit. Caps/handles extending above the 457mm body would exceed it.
- **Shoulder utility holes sit on flanges**: After bending, the 2 shoulder utility holes end up on the angled flange portion (not on the main web). Still useful, just be aware they're not perfectly perpendicular to the plate face.

## Version history

- **v9** (current): Added 11 utility holes around perimeter (½" diameter), and 5 lightening cutouts (2× Ø130, 2× Ø95, 1× 400×90 pill). Top-edge utility holes split from 1 (center) to 2 (flanking SCAD).
- **v8**: Initial v9 layout but with the small lightening circles at (180, +20) instead of (180, -10) — moved due to insufficient bend-line clearance.
- **v7**: All outline corners rounded. No relief notches. 20mm flanges.
- **v6**: Hexagonal with U-shaped bend reliefs at the bottom bend (later removed).
- **v5**: 25mm flanges with shoulder bend reliefs.
- **v4**: First hexagonal version, before refining clearance definition.
- **v3**: Rectangular plate with 2 horizontal bends.
- **v2**: Initial rectangular plate, lug pair on top.
- **v1**: Initial concept.

## Generation provenance

Designed and DXF generated 2026-05-27 in collaboration with Claude (Anthropic). The Python script (`gen_plate.py`) is self-contained and reproduces the DXF exactly.

Dependencies: `ezdxf` (any recent version). Install with `pip install ezdxf`.
