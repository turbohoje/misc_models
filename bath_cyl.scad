$fn = 100;

difference(){
cylinder(30, 10, 10);
	translate([0,0,-1])
		cylinder(35, 2.5, 2.5);
	#translate([0,0,23])
		cylinder(10, 0, 10);
	
}