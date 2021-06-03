// dimensions of the nice!nano mcu
nn_w = 18.2
nn_l = 33.3
nn_d = 1.6
nn_usb_d = 3.15
nn_usb_w = 8.9

// tolerance 
tol = 0.2 

// external dimensions
wall = 2.0
skirt = 6.0
screw_hole = 3.0
holder_inset = 0.4
wire_room 3.0
battery_room 2.0

// we'll do these one half at a time and then mirror
module half(){
    union(){
        cube([
            nn_w / 2 - holder_inset + wall,  // half of this
            nn_l + wall * 2, 
            nn_d + wire_room + battery_room + wall * 2
        ])
    }
}

// todo2
// - [ ] bottom plate
// - [ ] screw countersinks
// - [ ] front plate
// - [ ] mcu side holder
// - [ ] mcu backstop block
// - [ ] 