$fn = 150;
//https://www.thingiverse.com/thing:4721933

batteryR = 23.6/2;
caseR = batteryR + 2;
caseH = 92/2;

rotate([90,0,0])
translate([0,0,29])
import("files/Gopro_Max_usb_bottom_part.stl");

cylinder(h = 6, r1 = 6, r2 = caseR);

translate([0,0,5.9])
	difference(){
		cylinder(h = caseH, r1 = caseR, r2 = caseR);
		translate([0,0,2])
		cylinder(h = caseH, r1 = batteryR, r2 = batteryR);
		translate([0,0,caseH/2+5])
		cube([3*caseR,2,caseH], center=true);
	}