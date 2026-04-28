$fn = 60;

render_mode = 2; // [0:Bottom Tray, 1:Top Lid, 2:Both (Exploded)]

// --- Extracted Board Coordinates ---
usb_top_x = [19.94, 32.64, 45.34, 58.04, 70.74, 83.44];
usb_bot_x = [19.94, 32.64, 45.34, 58.04, 70.74, 83.44];
usb_in_y = 117.35;

h1 = [10.41, 140.21];
h2 = [92.58, 140.34];
h3 = [92.58, 93.98];
h4 = [10.29, 93.85];

// --- Case Boundaries ---
// Tightly bounds the 4 corner standoffs symmetrically
case_min_x = 7.2;
case_max_x = 95.7;
case_min_y = 90.8;
case_max_y = 143.5;

case_width = case_max_x - case_min_x;
case_length = case_max_y - case_min_y;
wall_thickness = 2.0;

// --- Z-Axis Hardware Stack (Bottom Up) ---
base_thickness = 2.0;
standoff_h = 4.0;
pcb_thickness = 1.6;

// Center height of the USB-C receptacle above the PCB
usb_center_above_pcb = 1.6;
usb_z = base_thickness + standoff_h + pcb_thickness + usb_center_above_pcb;

clearance_above_pcb = 12.0;
total_internal_height = standoff_h + pcb_thickness + clearance_above_pcb;

// --- Fit Tolerances & Shapes ---
fit_tolerance = 0.05; // Gap for the friction lid
u_slot_w = 11.5; // Width of the slots for the USBs to slide down

explode_dist = (render_mode == 2) ? 25 : 0;


// --- True USB-C Pill Shape Profile ---
module usb_c_profile(depth=10) {
    w = 9.5;
    h = 3.5;
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module bottom_tray() {
    difference() {
        // Main solid block
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
            cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height + base_thickness]);

        // Hollow interior
        translate([case_min_x, case_min_y, base_thickness])
            cube([case_width, case_length, total_internal_height + 1]);

        // --- Subtract USB Outlines ---
        for(x = usb_top_x) translate([x, case_max_y, usb_z]) rotate([90, 0, 0]) usb_c_profile(wall_thickness * 4);
        for(x = usb_bot_x) translate([x, case_min_y, usb_z]) rotate([90, 0, 0]) usb_c_profile(wall_thickness * 4);

        // Left wall USB lays flat (0, 90, 90)
        translate([case_min_x, usb_in_y, usb_z]) rotate([90, 0, 90]) usb_c_profile(wall_thickness * 4);

        // --- Vertical U-Slots (Open to the top rim to allow drop-in assembly) ---
        // Top Row
        for(x = usb_top_x) {
            translate([x - u_slot_w/2, case_max_y - wall_thickness - 1, usb_z])
                cube([u_slot_w, wall_thickness + 2, total_internal_height]);
        }
        // Bottom Row
        for(x = usb_bot_x) {
            translate([x - u_slot_w/2, case_min_y - 1, usb_z])
                cube([u_slot_w, wall_thickness + 2, total_internal_height]);
        }
        // Left Side
        translate([case_min_x - wall_thickness - 1, usb_in_y - u_slot_w/2, usb_z])
            cube([wall_thickness + 2, u_slot_w, total_internal_height]);
    }

    standoff(h1);
    standoff(h2);
    standoff(h3);
    standoff(h4);
}

module top_lid() {
    // Moves the lid to its assembled height (plus explode distance)
    translate([0, 0, base_thickness + total_internal_height + explode_dist])
    difference() {
        union() {
            // Flat Roof
            translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
                cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, wall_thickness]);

            // Inner Friction Alignment Lip
            translate([case_min_x + fit_tolerance, case_min_y + fit_tolerance, -3])
                difference() {
                    cube([case_width - 2*fit_tolerance, case_length - 2*fit_tolerance, 3]);
                    translate([wall_thickness, wall_thickness, -1])
                        cube([case_width - 2*fit_tolerance - 2*wall_thickness, case_length - 2*fit_tolerance - 2*wall_thickness, 5]);
                }

            // --- Downward Filler Tabs (Fill the U-Slots) ---
            tab_drop = total_internal_height + base_thickness - usb_z;

            // Top Row Tabs
            for(x = usb_top_x) {
                translate([x - u_slot_w/2 + fit_tolerance, case_max_y + fit_tolerance, -tab_drop])
                    cube([u_slot_w - 2*fit_tolerance, wall_thickness - 2*fit_tolerance, tab_drop]);
            }
            // Bottom Row Tabs
            for(x = usb_bot_x) {
                translate([x - u_slot_w/2 + fit_tolerance, case_min_y - wall_thickness + fit_tolerance, -tab_drop])
                    cube([u_slot_w - 2*fit_tolerance, wall_thickness - 2*fit_tolerance, tab_drop]);
            }
            // Left Tab
            translate([case_min_x - wall_thickness + fit_tolerance, usb_in_y - u_slot_w/2 + fit_tolerance, -tab_drop])
                cube([wall_thickness - 2*fit_tolerance, u_slot_w - 2*fit_tolerance, tab_drop]);
        }

        // --- Subtract USB Outlines from the Tabs ---
        tab_z_local = -(total_internal_height + base_thickness - usb_z);
        for(x = usb_top_x) translate([x, case_max_y, tab_z_local]) rotate([90, 0, 0]) usb_c_profile(wall_thickness * 4);
        for(x = usb_bot_x) translate([x, case_min_y, tab_z_local]) rotate([90, 0, 0]) usb_c_profile(wall_thickness * 4);

        // Left wall USB shape subtraction lays flat
       translate([case_min_x, usb_in_y, tab_z_local]) rotate([90, 0, 90]) usb_c_profile(wall_thickness * 4);
    }
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=6, h=standoff_h);
        translate([0,0,1]) cylinder(d=2.2, h=standoff_h);
    }
}

if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") bottom_tray();
}

if (render_mode == 1 || render_mode == 2) {
    color("LightGray") top_lid();
}
