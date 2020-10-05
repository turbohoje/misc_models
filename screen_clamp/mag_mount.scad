$fn = 50;

magnet_rad = 26/2;
pin_rad = 5.5/2;
thick = 5;



//base
linear_extrude(thick)
square([45, 90], center=true);


//virt
difference(){
	union(){
		translate([22,0,0])
		rotate([0,90,0])
		linear_extrude(thick)
		square([20,90], center=true);
	}
	
	//string
	translate([20,0,-5])
	rotate([0,90,0])
	cylinder(h=20, r=pin_rad, center=true);
	
	//mag holes
	
}


translate([0,-45+thick,0])
gusset();

translate([0,45,0])
gusset();



module gusset(){
rotate([90,0,0])
linear_extrude(thick)
polygon(points=[
	[-22,0],
	[22,-10],
	[22,0]
]);
}
