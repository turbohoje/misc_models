$fn = 150;
wall_dia = 22;
pipe_dia = 35;
wall_height = 50;

linear_extrude(10)
difference() {
    union(){
        hull() {
            translate([0, - wall_height, 0]) {
                circle(d = wall_dia + 20);
            }
            circle(d = pipe_dia + 29);
            translate([(wall_dia+20/2) - pipe_dia/4, + 2*wall_height, 0]) {
                circle(d = pipe_dia /2);
            }
        }
        hull(){
            circle(d = pipe_dia + 29);
            translate([-(wall_dia+20/2) + pipe_dia/4, + 2*wall_height, 0]) {
                circle(d = pipe_dia /2);
            }
        }
    }

    translate([0, - 25, 0])
        hull() {
            translate([0, - wall_height, 0]) {
                circle(d = wall_dia);
            }
            circle(d = wall_dia);
        }

    translate([0, 25, 0])
        hull() {
            translate([0, 3*pipe_dia, 0]) {
                circle(d = pipe_dia);
            }
            circle(d = pipe_dia);
        }

}