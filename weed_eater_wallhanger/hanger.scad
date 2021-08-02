$fn = 50;

mm_in_inches = 25.4;

cutRadius = 9*mm_in_inches;
cutHeight = 2*mm_in_inches;

difference(){
	hull(){
		translate([(1.5 * mm_in_inches)/-2,0,0])
		cube([
			1.5 * mm_in_inches,
			1.5 * mm_in_inches,
			4 * mm_in_inches
		]);
		translate([-3.5*mm_in_inches,0, 3*mm_in_inches])
		cube([
			7*mm_in_inches,
			4*mm_in_inches,
			4*mm_in_inches
		]);
	}
	translate([0,0,12 * mm_in_inches])
		rotate([-90,0,0]){
			translate([0,0,-.5])
			cylinder(2*mm_in_inches+1, r=cutRadius);
			translate([0,0,2*mm_in_inches])
				cylinder(h=2*mm_in_inches+1, r1=cutRadius, r2=cutRadius-(2*mm_in_inches));
		}
	
	//screw cuts
	rotate([90,0,0])
		translate([0,60,-250 - mm_in_inches])
			union(){
				cylinder(r=1.75, h=500);
				cylinder(r=5, h=250);
				translate([0,0,250])
				cylinder(r1=5, r2=1.75, h=4);
			}
		
	rotate([90,0,0])
		translate([0,20,-250 - mm_in_inches])
			union(){
				cylinder(r=1.75, h=500);
				cylinder(r=5, h=250);
				translate([0,0,250])
				cylinder(r1=5, r2=1.75, h=4);
			}
}