// dimensions of the nice!nano mcu
nn_w = 18.2;
nn_l = 33.3;
nn_d = 1.6;
nn_usb_d = 3.15;
nn_usb_w = 8.9;

// tolerances
tol = 0.2;
$fs = 0.5;

// external dimensions
wall = 2.0;

// countersunk screw 
screw_r = 2.3;
countersink_r = 4.7;

// holder
holder_inset = 0.4;
padding_top = 1.0;
padding_bottom = 2.0;

// backstop
// backstop_screw_r = 3.2/2 + 2*tol;
// backstop_screw_head_r = 7.65/2 + tol;
bs_w = 3.0;
bs_l = 2.0;

// front plate
box_height = 10.0;
cable_port_d = 0.3;

// bottom plate
skirt = 11.0;
bp_padding_bottom = 20.0 - wall; // oops. bad measurement. adjusting...
bp_left_shaft = 40.0;
bp_left_shaft_w = 10;
floor_d = 3.5;

// reset switch

rs_w = 3.5 + 2*tol;
rs_l = 6 + 2*tol;
rs_d = 3.5;
rs_inset_d = 1.5;
rs_inset = 3;
rs_leg_d = 1.5; // leg hole diameter


// todo2
// - [x] bottom plate
// - [x] screw countersinks
// - [x] front plate
// - [x] mcu side holder
// - [x] mcu backstop block
// - [ ] reset switch hollow (box w/ 2 holes)
// - [x] pick out and measure both screws

// modules

module holder_side(){
    rotate([90,0,0]) mirror([0,0,1]){
    linear_extrude(height=nn_l){
        polygon(points=[
            [0-wall,0], // origin
            [0-wall,padding_top + padding_bottom + nn_d], // top left
            [holder_inset,padding_top + padding_bottom + nn_d], // top right

            [holder_inset,  padding_bottom + nn_d],
            [-1*tol/2, padding_bottom + nn_d],
            [-1*tol/2, padding_bottom],
            [holder_inset, padding_bottom],
            [holder_inset, 0]
        ]);
    };
    };
};

module holder() {
    holder_side();
    translate([nn_w,0,0]) mirror([1, 0, 0]) {
        holder_side();
    }
}

module support(side) {
    rotate([0,90,0]) linear_extrude(wall-tol) polygon(points=[
        [0,0], [0,-side],[-side,0]
    ]);
}

module front_plate() {
    translate([-1*wall, nn_l, 0]) union() {
        difference(){
            cube([nn_w + 2*wall, wall, box_height+wall*2]);
            # translate([nn_usb_d/2 + wall + (nn_w - nn_usb_w) / 2,  0, nn_usb_d/2 + padding_bottom]) rotate([90,0,0]) mirror([0,0,1]) linear_extrude(wall+tol) hull() {
                circle(d=nn_usb_d+2*(tol+cable_port_d));
                translate([nn_usb_w-nn_usb_d,0]) circle(d=nn_usb_d+2*(tol+cable_port_d));
            }
        }
        support(box_height+wall);
        translate([nn_w+wall+tol,0,0]) support(box_height+wall);
    }
}


module backstop() {
    translate([0,-wall]) union() {
        translate([nn_w/2 - bs_w/2,-bs_l,0]) cube([bs_w, bs_l,padding_bottom-tol]);
        translate([-wall,-tol/2,0]) support(padding_top + padding_bottom + nn_d);
        translate([nn_w+wall+tol/2,0,0]) translate([-wall,-tol,0]) support(padding_top + padding_bottom + nn_d);
    }

    // separate bar to lock things in place
    translate([nn_w+wall+skirt*2, 0, -floor_d]) {
        cube([padding_top + padding_bottom + nn_d, nn_w+wall*2, wall]);
        
    }
}


module countersink() {
    #cylinder(h=floor_d,r1=screw_r,r2=countersink_r);
}


module truncated_pyramid(sides,outset) {
    // from example: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
    // top face is outset `outset` units from bottom.
    polyhedron( [
            [  0,  0,  0 ],  //0
            [ sides.x,  0,  0 ],  //1
            [ sides.x,  sides.y,  0 ],  //2
            [  0,  sides.y,  0 ],  //3
            [  0-outset,  0-outset,  sides.z ],  //4
            [ sides.x+outset,  0-outset,  sides.z ],  //5
            [ sides.x+outset,  sides.y + outset,  sides.z ],  //6
            [  0-outset,  sides.y + outset,  sides.z ]   //7
        ],
        [
            [0,1,2,3],  // bottom
            [4,5,1,0],  // front
            [7,6,5,4],  // top
            [5,6,2,1],  // right
            [6,7,3,2],  // back
            [7,4,0,3]  // left
        ]);
}


rs_origin = [0-rs_w,0-bp_padding_bottom+bp_left_shaft_w+wall-rs_l, floor_d];

module rs_hollow() {
    #translate(rs_origin) rotate([0,0,90]) translate([0,0,0-rs_d - rs_inset_d]) {
        cube([rs_l,rs_w,rs_d + rs_inset_d]);
        translate([0,0,rs_d]) truncated_pyramid([rs_l, rs_w, rs_inset_d], rs_inset);
        translate([rs_leg_d/2, rs_w/2, 0-floor_d]) cylinder(d=rs_leg_d, h=floor_d);
        translate([rs_l-rs_leg_d/2, rs_w/2, 0-floor_d]) cylinder(d=rs_leg_d, h=floor_d);
    }
}

module rs_hull() {
    translate(rs_origin) rotate([0,0,90]) mirror([0,0,1]) translate([0-wall, 0-wall, 0]){
        cube([rs_l+2*wall,rs_w+2*wall,wall+rs_d + rs_inset_d]);
    }

}

module bottom_plate() {
    mirror([0, 0, 1]) difference() {
        union(){
            linear_extrude(floor_d) polygon(points=[
                [0 - wall - skirt, nn_l + wall],
                [nn_w + wall + skirt, nn_l + wall],
                [nn_w + wall + skirt, 0-bp_padding_bottom-skirt],
                [0-bp_left_shaft, 0-bp_padding_bottom-skirt],
                [0-bp_left_shaft, 0-bp_padding_bottom+bp_left_shaft_w+skirt],
                [0-wall-skirt, 0-bp_padding_bottom+bp_left_shaft_w+skirt],
            ]);
            rs_hull();
        }

        // screws
        translate([skirt/-2-wall,nn_l-skirt/2,0]) countersink();
        translate([skirt/2+nn_w+wall,nn_l-skirt/2,0]) countersink();
        translate([skirt/2+nn_w+wall,0- bp_padding_bottom- skirt/2,0]) countersink();
        // translate([0-bp_left_shaft+skirt/2,0- bp_padding_bottom- skirt/2,0]) countersink();
        // translate([0-bp_left_shaft+skirt/2,0-bp_padding_bottom+bp_left_shaft_w+skirt/2,0]) countersink();
        translate([0-wall-skirt/2,0- bp_padding_bottom- skirt/2,0]) countersink();

        rs_hollow();
    }
        
    
        
}


// main

holder();
backstop();
front_plate();
bottom_plate();


// todo: 
// - [x] supports on side of frontplate
// - [x] tighter holder
// - [s] redesign backstop
// - [x] move rest switch box

