#!/usr/bin/env python3
"""
rack_blank_panel.py

Generates a DXF drawing of a parametrized rack "blank-off" / filler panel
for a standard 19" EIA-310 server rack, sized by number of rack units (U).

All dimensions default to the EIA-310-D standard, but are exposed as
parameters so the panel can be adapted to non-standard rails, screw
sizes, or fabrication clearances.

Usage (CLI):
    python3 rack_blank_panel.py 11                     # 11U panel, blank_panel_11U.dxf
    python3 rack_blank_panel.py 11 -o my_panel.dxf
    python3 rack_blank_panel.py 11 --hole-diameter-in 0.201 --mount-style all

Usage (import):
    from rack_blank_panel import PanelSpec, build_panel
    spec = PanelSpec(u=11)
    doc = build_panel(spec)
    doc.saveas("blank_panel_11U.dxf")

--------------------------------------------------------------------------
EIA-310-D reference dimensions (the defaults used below)
--------------------------------------------------------------------------
- 1 Rack Unit (U)                    : 1.75 in   (44.45 mm)
- Horizontal hole spacing (rail-to-rail,
  center of left column to center
  of right column)                   : 18.312 in (465.1 mm)
- Nominal front panel / rack width   : 19.0 in   (482.6 mm)
- Panel height fabrication clearance : 1/32 in   (0.79 mm) less than
                                        (U * 1.75in), so adjacent panels
                                        don't bind against each other.
- Vertical hole pattern per U (3 holes/U, "universal spacing"),
  measured from the BOTTOM of each U, hole centers at:
        0.250 in  (6.350 mm)
        0.875 in  (22.225 mm)
        1.500 in  (38.100 mm)
  Gaps between holes, bottom to top: 0.5" - 0.625" - 0.625" - 0.5"(next U)
- Clearance hole diameter (for #10-32, #12-24, or M6 screw + cage nut) :
        9/32 in (0.281 in / 7.14 mm)  -- generous clearance hole.
        Use --hole-diameter-in to size for a specific screw if you are
        NOT using cage nuts / clip nuts (e.g. 0.190" for a #10 screw
        clearance fit, 0.201" for 1/4-20 clearance, etc).
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from typing import List, Literal, Sequence

import ezdxf
from ezdxf.document import Drawing

IN_TO_MM = 25.4


@dataclass
class PanelSpec:
    # ---- required ----
    u: float = 1  # number of rack units (can be fractional, e.g. 0.5U vented panels)

    # ---- EIA-310 standard dimensions (override only for non-standard rails) ----
    u_height_in: float = 1.75              # height of 1 rack unit
    hole_spacing_horiz_in: float = 18.312   # left-column-to-right-column hole spacing
    panel_width_nominal_in: float = 19.0    # nominal "19 inch" rack width
    panel_height_clearance_in: float = 1.0 / 32.0  # subtracted from U*u_height for fit
    hole_diameter_in: float = 0.281         # 9/32" clearance hole (cage nut friendly)
    hole_offsets_in: Sequence[float] = field(
        default_factory=lambda: (0.250, 0.875, 1.500)
    )  # the 3 EIA hole centers, measured from the bottom of a U, bottom-up

    # ---- mounting hole selection ----
    # 'ends'          -> just the outermost EIA hole at the very top and
    #                    very bottom of the panel (2 holes x 2 columns = 4 total)
    # 'ends_and_mid'  -> 'ends' plus one extra hole roughly at the panel's
    #                    vertical midpoint, snapped to the nearest valid
    #                    EIA hole position (good for U >= 6 to stop sag/bow)
    # 'every_u'       -> one hole per U (uses hole_index_per_u position within
    #                    every U) x 2 columns
    # 'all'           -> every EIA hole position (3 per U) x 2 columns
    mount_style: Literal["ends", "ends_and_mid", "every_u", "all"] = "ends_and_mid"
    hole_index_per_u: int = 1  # which of the 3 hole_offsets_in to use for 'every_u' (0,1,2)

    # ---- cosmetic ----
    corner_radius_in: float = 0.0   # 0 = square corners
    label_text: str = ""            # optional text etched/engraved in the panel (e.g. "11U BLANK")
    label_height_in: float = 0.25

    # ---- units for the output DXF ----
    units: Literal["in", "mm"] = "in"

    # -------- derived geometry (computed, not set directly) --------
    @property
    def panel_height_in(self) -> float:
        return self.u * self.u_height_in - self.panel_height_clearance_in

    @property
    def panel_width_in(self) -> float:
        # Standard practice: actual panel width is very slightly under the
        # nominal 19" so it doesn't bind against rack rail flanges.
        # Re-uses the same clearance convention as the height for consistency.
        return self.panel_width_nominal_in - self.panel_height_clearance_in

    def to_scale(self) -> float:
        """Multiplier to convert this spec's inch dimensions to the output units."""
        return 1.0 if self.units == "in" else IN_TO_MM


def _hole_y_positions(spec: PanelSpec) -> List[float]:
    """
    Returns the Y coordinates (in inches, measured from the bottom edge of
    the panel) of every hole that should be drilled, according to
    spec.mount_style.
    """
    n_units = spec.u
    # y-position of the bottom-most and top-most EIA hole *within the rack*,
    # relative to the panel's own bottom edge. The panel is centered on the
    # U grid with panel_height_clearance_in split evenly top/bottom.
    half_clearance = spec.panel_height_clearance_in / 2.0

    # All EIA hole positions across the full stack of U's, measured from the
    # bottom of the bottommost U (before applying the half-clearance offset).
    all_positions = []
    n_full_units = int(round(n_units)) if float(n_units).is_integer() else None
    if n_full_units is None:
        raise ValueError("u must currently be a whole number of rack units")
    for u_index in range(n_full_units):
        base = u_index * spec.u_height_in
        for offset in spec.hole_offsets_in:
            all_positions.append(base + offset)
    all_positions.sort()

    if spec.mount_style == "all":
        chosen = all_positions
    elif spec.mount_style == "every_u":
        idx = spec.hole_index_per_u
        chosen = [
            u_index * spec.u_height_in + spec.hole_offsets_in[idx]
            for u_index in range(n_full_units)
        ]
    elif spec.mount_style in ("ends", "ends_and_mid"):
        chosen = [all_positions[0], all_positions[-1]]
        if spec.mount_style == "ends_and_mid" and n_full_units >= 4:
            mid_target = all_positions[-1] / 2.0
            mid_hole = min(all_positions, key=lambda p: abs(p - mid_target))
            if mid_hole not in chosen:
                chosen.append(mid_hole)
    else:
        raise ValueError(f"Unknown mount_style: {spec.mount_style!r}")

    # shift from "bottom of bottommost U" coordinate frame to "bottom of panel"
    return sorted(y + half_clearance for y in chosen)


def build_panel(spec: PanelSpec) -> Drawing:
    """Build and return an ezdxf Drawing for the given PanelSpec."""
    scale = spec.to_scale()
    doc = ezdxf.new("R2010", setup=True)
    doc.units = ezdxf.units.MM if spec.units == "mm" else ezdxf.units.IN
    msp = doc.modelspace()

    doc.layers.add("OUTLINE", color=7)
    doc.layers.add("HOLES", color=1)
    doc.layers.add("LABEL", color=3)
    doc.layers.add("CENTERLINES", color=8)

    w = spec.panel_width_in * scale
    h = spec.panel_height_in * scale
    r = spec.corner_radius_in * scale

    # ---- outline ----
    if r <= 0:
        msp.add_lwpolyline(
            [(0, 0), (w, 0), (w, h), (0, h)],
            close=True,
            dxfattribs={"layer": "OUTLINE"},
        )
    else:
        pts = [
            (r, 0), (w - r, 0),
            (w, 0), (w, r),          # bulge handled below via arcs
        ]
        # Build a rounded rectangle explicitly with lines + arcs for clarity.
        msp.add_line((r, 0), (w - r, 0), dxfattribs={"layer": "OUTLINE"})
        msp.add_arc((w - r, r), r, 270, 360, dxfattribs={"layer": "OUTLINE"})
        msp.add_line((w, r), (w, h - r), dxfattribs={"layer": "OUTLINE"})
        msp.add_arc((w - r, h - r), r, 0, 90, dxfattribs={"layer": "OUTLINE"})
        msp.add_line((w - r, h), (r, h), dxfattribs={"layer": "OUTLINE"})
        msp.add_arc((r, h - r), r, 90, 180, dxfattribs={"layer": "OUTLINE"})
        msp.add_line((0, h - r), (0, r), dxfattribs={"layer": "OUTLINE"})
        msp.add_arc((r, r), r, 180, 270, dxfattribs={"layer": "OUTLINE"})

    # ---- mounting holes ----
    hole_r = (spec.hole_diameter_in / 2.0) * scale
    x_col = (spec.hole_spacing_horiz_in / 2.0) * scale
    x_left = w / 2.0 - x_col
    x_right = w / 2.0 + x_col

    hole_ys = [y * scale for y in _hole_y_positions(spec)]
    for y in hole_ys:
        msp.add_circle((x_left, y), hole_r, dxfattribs={"layer": "HOLES"})
        msp.add_circle((x_right, y), hole_r, dxfattribs={"layer": "HOLES"})

    # thin construction lines showing the two hole columns (handy when
    # eyeballing the DXF in a viewer; delete the CENTERLINES layer before
    # sending to a fab shop if you don't want them cut/etched)
    msp.add_line((x_left, 0), (x_left, h), dxfattribs={"layer": "CENTERLINES", "linetype": "DASHDOT"})
    msp.add_line((x_right, 0), (x_right, h), dxfattribs={"layer": "CENTERLINES", "linetype": "DASHDOT"})

    # ---- optional label ----
    if spec.label_text:
        th = spec.label_height_in * scale
        msp.add_text(
            spec.label_text,
            dxfattribs={
                "layer": "LABEL",
                "height": th,
                "insert": (w / 2.0, h / 2.0 - th / 2.0),
                "halign": 4,  # center
                "valign": 2,  # middle
                "align_point": (w / 2.0, h / 2.0),
            },
        ).set_placement((w / 2.0, h / 2.0), align=ezdxf.enums.TextEntityAlignment.MIDDLE_CENTER)

    return doc


def default_output_name(spec: PanelSpec) -> str:
    u_str = str(spec.u).rstrip("0").rstrip(".") if isinstance(spec.u, float) else str(spec.u)
    return f"blank_panel_{u_str}U.dxf"


def _parse_args() -> PanelSpec:
    p = argparse.ArgumentParser(description="Generate a DXF for an EIA-310 rack blank-off panel.")
    p.add_argument("u", type=float, help="Number of rack units (U), e.g. 11")
    p.add_argument("-o", "--output", type=str, default=None, help="Output DXF filename")
    p.add_argument("--units", choices=["in", "mm"], default="in", help="Output DXF units (default: in)")

    p.add_argument("--u-height-in", type=float, default=1.75, help="Height of 1 rack unit (default EIA: 1.75in)")
    p.add_argument("--hole-spacing-horiz-in", type=float, default=18.312,
                    help="Center-to-center horizontal hole spacing (default EIA: 18.312in)")
    p.add_argument("--panel-width-nominal-in", type=float, default=19.0,
                    help="Nominal rack width (default: 19in)")
    p.add_argument("--panel-height-clearance-in", type=float, default=1.0 / 32.0,
                    help="Fabrication clearance subtracted from U*u_height (default: 1/32in)")
    p.add_argument("--hole-diameter-in", type=float, default=0.281,
                    help="Mounting hole clearance diameter (default EIA: 0.281in / 9/32in)")
    p.add_argument("--corner-radius-in", type=float, default=0.0, help="Corner fillet radius (default: 0, square)")

    p.add_argument("--mount-style", choices=["ends", "ends_and_mid", "every_u", "all"],
                    default="ends_and_mid", help="Which EIA holes to actually drill (default: ends_and_mid)")
    p.add_argument("--hole-index-per-u", type=int, default=1, choices=[0, 1, 2],
                    help="For --mount-style every_u: which of the 3 EIA holes per U to use (0,1,2)")

    p.add_argument("--label", type=str, default="", help="Optional text label engraved/etched in the panel")

    args = p.parse_args()

    spec = PanelSpec(
        u=args.u,
        u_height_in=args.u_height_in,
        hole_spacing_horiz_in=args.hole_spacing_horiz_in,
        panel_width_nominal_in=args.panel_width_nominal_in,
        panel_height_clearance_in=args.panel_height_clearance_in,
        hole_diameter_in=args.hole_diameter_in,
        corner_radius_in=args.corner_radius_in,
        mount_style=args.mount_style,
        hole_index_per_u=args.hole_index_per_u,
        label_text=args.label,
        units=args.units,
    )
    spec._output = args.output  # stash for main()
    return spec


def main():
    spec = _parse_args()
    doc = build_panel(spec)
    out = spec._output or default_output_name(spec)
    doc.saveas(out)
    print(f"Wrote {out}")
    print(f"  Panel size : {spec.panel_width_in:.4f} in x {spec.panel_height_in:.4f} in "
          f"({spec.panel_width_in * IN_TO_MM:.2f} mm x {spec.panel_height_in * IN_TO_MM:.2f} mm)")
    print(f"  Mount style: {spec.mount_style}  |  Hole dia: {spec.hole_diameter_in}in "
          f"({spec.hole_diameter_in * IN_TO_MM:.2f}mm)")
    print(f"  Hole rows  : {len(_hole_y_positions(spec))} (x2 columns = {2 * len(_hole_y_positions(spec))} holes total)")


if __name__ == "__main__":
    main()
