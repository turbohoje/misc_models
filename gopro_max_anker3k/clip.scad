$fn = 100;

batteryR = 23.6/2;
caseR = batteryR + 2;
caseH = 92;
clipL = 3;

translate([0,00])
	difference(){
		union(){
			cylinder(h = caseH, r1 = caseR, r2 = caseR);
			translate([0,3.8,caseH/2-20]) {
				cube([60, 10, 40]);
				translate([20,0,0])  //extra hump
				cube([30, 13.5, 40]);
			}
		}
		translate([15,0,caseH/2-8])  //cut out to straddle the gopro
			cube([200,20,16]);
		translate([0,0,3])
			cylinder(h = caseH, r1 = batteryR, r2 = batteryR);
		translate([0,-caseR/2-2,caseH/2-.1]) //change to a whole cut for top half
			cube([3*caseR,caseR,caseH+2], center=true);

		//zip tie hoel
//		for(i = [0 : 1])
//		translate([55-i*10,8.8,0])
//			cylinder(h = caseH, r1 = 3, r2 = 3);


	}

//tines to hold this oh
translate([43,7,caseH/2-8])
rotate([90,0,0])
	linear_extrude(height=clipL) {
		spine();
		translate([0,16,0])
			mirror(v=[0,1,0])
				spine();
	}

module spine(){
	polygon(points=[[2*clipL,0],[clipL,0],[clipL,clipL]]);
}