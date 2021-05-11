$fn = 50;

thickness_mm = 51;
big_mm = 35;
small_mm = 6;
small_radius = big_mm + 10;
bolts = 4;


linear_extrude(thickness_mm){
	
	for(i = [0:bolts]){
		hull(){
			circle(small_mm);
			translate([small_radius * sin(i*360/bolts), small_radius * cos(i*360/bolts), 0]){
				circle(small_mm);
			}
		}
	}
	circle(big_mm);
	
}