//female to female vacuum host fitting

$diameter = 57.8; //mm
$height = 30; //mm 25.1 mm in an inch
$wall = 5;
$ecc = .5;

$fn = 150;


difference(){
	cylinder($height, $diameter/2 + $wall, $diameter/2 + $wall, center=true);
	
	translate([0,0,-1])
		cylinder($height/2+1.1, $diameter/2-$ecc, $diameter/2+$ecc);
	translate([0,0,-$height/2-1])
		cylinder($height/2+1, $diameter/2+$ecc, $diameter/2-$ecc);
	
}