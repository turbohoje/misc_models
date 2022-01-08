$fn = 150;

// cleat dimensions
$c_width = 37;
$c_maj_width = 43;
$c_height = 15;

// tube dimensions
$tube_radius = 81.5/ 2;
$strap_thick = 1.5;

//cut width
$cut = 1;


linear_extrude(height = 100) {
    difference() {
        union() {
            translate([0, $tube_radius - $c_height / 2, 0])
                polygon([
                        [$c_maj_width / 2, $c_height],
                        [- $c_maj_width / 2, $c_height],
                        [- $c_width / 2, 0],
                        [$c_width / 2,0]
                    ]);
            circle($tube_radius + $strap_thick);
        }
        circle($tube_radius);
        // v bend relief
        polygon([
                [-$c_height, $tube_radius-$c_height],
                [0, $tube_radius+(($c_height-$strap_thick)/4)],
                [-$c_height, $tube_radius+$c_height],

                [-$c_height+$cut, $tube_radius+$c_height],
                [$cut, $tube_radius+(($c_height-$strap_thick)/4)],
                [-$c_height+$cut, $tube_radius-$c_height],
            ]);
    }
}

