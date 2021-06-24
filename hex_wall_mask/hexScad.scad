$fn = 50;

length = 95;
thick  = 80;
sides = 6;
angle = (sides-2)*180 / sides; // (n-2)*180 /n
gap = 10;

translate([gap/2,gap/2,0])
hex_cap();

mirror(v=[.5,.5,0])
	rotate([0,0,-(180/6)])
		hex_cap();

translate([0,-length,0])
	translate([
			0      + gap * cos(angle/2), 
			length + gap * sin(angle/2), 
		0])
	rotate([0,0,-angle/2])
		translate([
				0      + gap * cos(angle/2), 
				length + gap * sin(angle/2), 
			0])
		rotate([0,0,-angle/2])
			translate([
					0,
					length + 2*gap * sin(angle/2),
				0])
				hex_cap();


module hex_cap(){
	hex_leg_half_open(edge_beg=1);
	
	translate([
		0      + gap * cos(angle/2), 
		length + gap * sin(angle/2), 
	0])
		rotate([0,0,-angle/2])
			hex_leg_closed();
	
	translate([
		0      + gap * cos(angle/2), 
		length + gap * sin(angle/2), 
	0])
		rotate([0,0,-angle/2])
				translate([
				0      + gap * cos(angle/2), 
				length + gap * sin(angle/2), 
			0])
				rotate([0,0,-angle/2])
					hex_leg_closed();
	
	translate([
		0      + gap * cos(angle/2), 
		length + gap * sin(angle/2), 
	0])
		rotate([0,0,-angle/2])
				translate([
					0      + gap * cos(angle/2), 
					length + gap * sin(angle/2), 
				0])
					rotate([0,0,-angle/2])
						translate([
							0      + gap * cos(angle/2), 
							length + gap * sin(angle/2), 
						0])
							rotate([0,0,-angle/2])
								hex_leg_half_open(edge_end=1);
}

module hex_leg_closed(){
	polygon([
		[0,0],
		[0,length],
		[thick,length-thick*sin(angle/3.4)],
		[thick,thick*sin(angle/3.4)]
	]);
}

module hex_leg_half_open(edge_beg=0, edge_end=0){
	
	polygon([
		[0,0],
		[0,length],
		[thick,length-thick*sin(angle/3.4) + 2*edge_end*thick*sin(angle/3.4)],
		[thick,thick*sin(angle/3.4)-2*edge_beg*thick*sin(angle/3.4)]
	]);

}