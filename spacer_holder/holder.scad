$fn = 150;

cyl_base = 75;
pipe_dia = 33.68;
pipe_dia_cut = 35;
height   = 75;
wall_dia = 25;
pipe_rad = pipe_dia/2;
cyl_top = pipe_rad + 4;

difference(){
    cylinder(height, cyl_base, cyl_top);
    translate([0,0,4])
    cylinder(height+1, pipe_rad, pipe_rad+.5);

    translate([0, 55,-10]){
    linear_extrude(height+10)
        hull() {
            translate([0, 3*pipe_dia_cut, 0]) {
                circle(d = pipe_dia_cut);
            }
            circle(d = pipe_dia_cut);
        }
    }

    translate([0, - 45,-10])
        linear_extrude(height+10)
        hull() {
            translate([0, - 35, 0]) {
                circle(d = wall_dia);
            }
            circle(d = wall_dia);
        }
}

//linear_extrude(height = 10,  convexity = 10)
//difference(){
//    square([290,290]);
//    import(file = "crusoe.dxf");
//}