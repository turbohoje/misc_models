$fn = 100;

difference(){
	
	hull(){
		translate([0,0, 100])
			rotate([90, 0, 0])
			cylinder(40, 10, 10);
		
		linear_extrude(10)
			square(100, 100, center=true);
	}
	
	translate([-40,-10,60])
	rotate([90, -20, 90])
	linear_extrude(100)
	polygon([
		[0,0],
		[13,0],
		[16, 60],
		[0, 60]

	]);
	
	translate([0,35,30])
	rotate([60,0,180])
	linear_extrude(height = 10) {
		text("AWL", size = 25, font="Liberation Sans", halign = "center", valign = "center", $fn = 16);
	}
}