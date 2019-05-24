$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt80adj = 0.3;
bt70adj = 0.3;
bt60adj = 0.2; // Fits nicely on Prusa.
bt55adj = 0.2;
bt50adj = 0.2;

r1 = bt60id/2 - bt60adj; 
wall = 3;

hollowCylinderAsBase(r1,2*wall,wall);
translate([0,0,wall])
hollowCylinderWithDrop(r1-wall,wall,wall);

