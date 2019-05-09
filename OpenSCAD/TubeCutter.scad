$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>

r1 = bt70od/2 + 0.3; // 0.3 for 70 and 80. 0.2 for 50 and 55.
wall = 3;
height = 1*inch;

hollowCylinderAsBase(r1+wall,wall,height);
