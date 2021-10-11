$fn = 150;

cyl_base = 75;
pipe_dia = 33.68;
height   = 75;

pipe_rad = pipe_dia/2;
cyl_top = pipe_rad + 4;

difference(){
    cylinder(height, cyl_base, cyl_top);
    translate([0,0,4])
    cylinder(height+1, pipe_rad, pipe_rad+.5);
}

//linear_extrude(height = 10,  convexity = 10)
//difference(){
//    square([290,290]);
//    import(file = "crusoe.dxf");
//}