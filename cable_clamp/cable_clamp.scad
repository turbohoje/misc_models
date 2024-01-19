$fn = 100;

$wire_dia  = 4.4;
$thick_dia = 9;
$len       = 30;
$wall      = 2;
$shank     = 5;

$wire_r = $wire_dia / 2;
$mid_r = $thick_dia /2;

rotate_extrude(angle=180, convexity=2)
polygon([
[$wire_r,-$shank],
[$wire_r,0],
[$mid_r,10],
[$mid_r,$len+10],
[$wire_r,$len+20],
[$wire_r,$len+20+$shank],

[$wire_r+$wall,$len+20+$shank],
[$wire_r+$wall,$len+20],
[$mid_r+$wall,$len+10],
[$mid_r+$wall,10],
[$wire_r+$wall,0],
[$wire_r+$wall,-$shank],
]);
