bt20id = 18.0;  // Motors ABC
bt50id = 24.1;  // Motors DE
bt52hid = 29.0; // Motors EFG
bt55id = 32.6;
bt60id = 40.6;
bt70id = 55.2;
bt80id = 65.0;

bt20od = 18.7;
bt50od = 24.8;
bt52hod = 31.0;
bt55od = 33.7;
bt60od = 41.7;
bt70od = 56.3;
bt80od = 66.0;

module hollowCylinderAsBase(r,wall,h)
{
    pts = [
        [r-wall,h],
        [r,h],
        [r,1],
        [r-1,0],
        [r-wall,0]];
    rotate_extrude()
    polygon(pts,convexity=2);
}

module cylinderAsBase(r,h)
{
    pts = [
        [0,h],
        [r,h],
        [r,1],
        [r-1,0],
        [0,0]];
    rotate_extrude()
    polygon(pts,convexity=2);
}

//cylinderAsBase(20,10);

module hollowCylinderWithDrop(r,wall,h)
{
    pts = [
        [r-wall,h],
        [r,h],
        [r,0],
        [r-wall/2,-wall/2],
        [r-wall,0]];
    rotate_extrude()
    polygon(pts,convexity=2);
}

module hollowConeWithDrop(r1,r2,wall,h)
{
    pts = [
    [r2-wall,h],
    [r2,h],
    [r1,0],
    [r1-wall/2,-wall/2],
    [r1-wall,0]];
    rotate_extrude()
    polygon(pts,convexity=2);
}

module hollowConeWithDropAndHole(r1,r2,wall,h)
{
    pts = [
    [r2-wall,h],
    [r2,h],
    [r1,0],
    [r1-wall/2,-wall/2],
    [r1-wall,0]];
    difference()
    {
        rotate_extrude()
        polygon(pts,convexity=2);
        translate([(r1+r2-wall)/2.0,0])
        cylinder(r=wall/1.5,h);
    }
}

// This is a spherical cap that has a slope of -1 at its edge.

module capWithDrop(r)
{
    rho = 1.414*r;
    translate([0,0,-r])
    intersection()
    {
        sphere(rho,$fn=50);
        cylinder(r1=0,r2=2*rho,h=2*rho);
        translate([-2*rho,-2*rho,r-1])
        cube(4*rho);
    }    
}

//capWithDrop(10);

/*
wall = 3;
h1 = 10;
h2 = 25;
h3 = 10;
hollowCylinderAsBase(bt55id/2,wall,h1);
translate([0,0,h1])
hollowConeWithDropAndHole(bt55od/2,bt70od/2,wall,h2);
translate([0,0,h1+h2])
hollowCylinderWithDrop(bt70id/2,wall,h3);
*/
