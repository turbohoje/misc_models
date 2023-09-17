$fn = 100;

inner_dia = 6.83;
outer_dia = 18.6;
thick     = 1.8;

module washer (inner, outer, thickness) {

	difference() {  
		cylinder(d=outer, h=thickness, $fn=60);  
		translate([0,0,-thickness])  
		cylinder(d=inner, h=thickness*3, $fn=60);  
	};  
}

washer (inner_dia, outer_dia, thick);