$fn = 100;

batteryR = 23.6/2;
caseR = batteryR + 2;
caseH = 92;

translate([0,00])
	difference(){
		union(){
			cylinder(h = caseH, r1 = caseR, r2 = caseR);
			translate([0,3.8,caseH/2-20])
				cube([60,10,40]);
		}
		translate([15,0,caseH/2-8])
			cube([200,16,16]);
		translate([0,0,3])
			cylinder(h = caseH, r1 = batteryR, r2 = batteryR);
		translate([0,0,caseH/2+5]) //slit for straddle
			cube([3*caseR,2,caseH], center=true);
		
		//zip tie hoel
		for(i = [0 : 2])
		translate([55-i*10,8.8,0])
			cylinder(h = caseH, r1 = 3, r2 = 3);
	}