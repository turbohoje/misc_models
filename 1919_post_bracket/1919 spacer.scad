$fn = 40;
size = (25.4 * 2) * pow(2,0.5);

height = 2.5 * 25.4;
cir = 34.92/2;

linear_extrude(height){
	difference(){
		hull(){
			polygon(points=[
				[0,0],
				[0,size],
				[size, 0]
			]);
			circle(cir + 2);
		polygon(points);
		}
		circle(cir);
		polygon(points=[
			[0,0],
			[-110,-95],
			[-95,-110]
		]);
	}
}