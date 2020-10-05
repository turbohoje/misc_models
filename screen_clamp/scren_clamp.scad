$fn = 40;


tooth_depth = 4;
height = 70;
beam_thick = -10;
thick = 10;

module clamp_leg(){	
	linear_extrude(thick)
	polygon(points=[
	[0,0],
	[tooth_depth,tooth_depth/2],
	[tooth_depth,tooth_depth],
	[0,tooth_depth],
	[0, 2*tooth_depth],
	[tooth_depth, 2*tooth_depth],
	[tooth_depth, height/2],
	[beam_thick, height],
	[beam_thick/2, 0]
	]);
	
}

linear_extrude(thick)
translate([0,height/2,0])
	difference(){
		circle(span/2);
		circle(span/2-4);
		translate([0,-span/2,0])
		square([span, span], center=true);
	}

span = 13;



translate([-span/2,0,0])
clamp_leg();

translate([span/2,0,0])
mirror([1,0,0])
clamp_leg();