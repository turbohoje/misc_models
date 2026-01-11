$fn = 50;

//mm
bolt_dia = 7;
bolt_flange = bolt_dia + 5;
bolt_spacing = 28;

tab_dia = 30;
tab_fwd = 95;
tab_len = 40;


module tab(){
    translate([0,0,-.1]);
    linear_extrude(3.5)
    difference(){
    //shape
    union(){
        hull(){
            translate([0,-30,0])
                circle(bolt_flange);
            
            translate([0,-30,0])
            rotate([0,0,90-70])
                translate([bolt_spacing+20, 0, 0])
                    circle(bolt_flange);
            
            //tab
            translate([-tab_dia/2,tab_fwd,0])
                circle(tab_dia/2);
        }
        hull(){
            //tab repeat
            translate([-tab_dia/2,tab_fwd,0])
                circle(tab_dia/2);
            //tab angle 
            translate([-tab_dia/2,tab_fwd + tab_len,0])
                circle(tab_dia/2);
        }
    }
            
            
    //bolt holes
    circle(bolt_dia/2);
    rotate([0,0,90-70])
        translate([bolt_spacing, 0, 0])
            circle(bolt_dia/2);
    }
}
color("black");
projection(cut=true)
tab();


/*
// BEND LINE (separate layer) use associated python code
projection(){
    color("red")
    layer("bends")
        translate([23, tab_fwd, 0])
            square([100, 0.1], center=false);
}
*/