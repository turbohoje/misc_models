$fn = 10;

h = 17;
d = 7.8;

cylinder(h, d/2, d/2); 
translate([0,0,h])
   cylinder(1, d/2, d/3); 