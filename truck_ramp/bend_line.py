#!/usr/bin/env python3
import ezdxf

# Open existing DXF file
doc = ezdxf.readfile("right_ramp_clip.dxf")
msp = doc.modelspace()

# Create a new layer for bends
doc.layers.add("BEND", color=1)  # color=1 is red

# Add a line on the BEND layer
# Line needs to exceed the part dims
y=95
msp.add_line(
    start=(-100, y),
    end=(100, y),
    dxfattribs={"layer": "BEND"}
)

# Save the modified DXF
doc.saveas("right_ramp_clip_bends.dxf")