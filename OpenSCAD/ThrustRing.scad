$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt52adj = 0.0; // 0.2 on TAZ. Trying 0.0 on Prusa. -0.05 is too tight.

rIn = bt52hid/2 + bt52adj;
echo(2*rIn/inch);
rOut = rIn + 3.0;
h = 6.0;

hollowCylinderAsBase(rOut,rOut-rIn,h);
