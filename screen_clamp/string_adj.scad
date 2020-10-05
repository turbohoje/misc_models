$fn = 50;

hole   = 4/2;
radius = 8/2;

linear_extrude(10)
difference(){
hull(){
	translate([0, radius, 0])
	circle(radius);
	translate([0,3*radius,0])
	circle(radius);
	translate([0,5*radius,0])
	circle(radius);
}
translate([0, radius, 0])
	circle(hole);
translate([0, 3*radius, 0])
	circle(hole);
translate([0, 5*radius, 0])
	circle(hole);
}