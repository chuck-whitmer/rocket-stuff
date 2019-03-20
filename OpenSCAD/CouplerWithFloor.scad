$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt80adj = 0.2;

r1 = bt80id/2-bt80adj;
r2 = 1;
wall = 2.4;

hollowCylinderAsBase(r1,r1-r2,0.33*inch);
translate([0,0,0.33*inch])
hollowCylinderWithDrop(r1,wall,1.67*inch);

