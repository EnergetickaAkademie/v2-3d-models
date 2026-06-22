$fn = 60;

board_w = 43.0;
board_h = 38.0;
// Restored for a tight fit around the PCB
board_clearance = 1.0;

usb_in_y_original = 125.73;

h1 = [13.46, 140.34];
h2 = [50.55, 140.46];
h3 = [50.42, 108.59];
h4 = [13.46, 108.59];

board_center_x = (h1[0] + h2[0] + h3[0] + h4[0]) / 4;
board_center_y = (h1[1] + h2[1] + h3[1] + h4[1]) / 4;

case_width = board_w + board_clearance;
case_length = board_h + board_clearance;

front_extension = 5.0;
case_min_x = board_center_x - (case_width / 2) - front_extension;
case_max_x = board_center_x + (case_width / 2);
case_min_y = board_center_y - (case_length / 2);
case_max_y = board_center_y + (case_length / 2);

wall_thickness = 1.5;
base_thickness = 2.0;
standoff_h = 2.5;
pcb_thickness = 1.6;

usb_center_below_pcb = 1.6;
usb_z = base_thickness + standoff_h - usb_center_below_pcb;
total_internal_height = standoff_h + pcb_thickness;
usb_in_y_flipped = board_center_y - (usb_in_y_original - board_center_y);

// --- FLEX TAB PARAMETERS ---
side_wall_t = 5.0; // Thickened side wall to house the flex mechanism safely
tab_start_x = case_min_x + 12.0; // Positioned along the side wall (X-axis insertion)
tab_l = 20.0;
slit_w = 1.0;
tab_protrusion = 2.0;

module pill(w, h, depth) {
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=5.5, h=standoff_h);
        translate([0,0,1]) cylinder(d=2.0, h=standoff_h);
    }
}

module slide_in_tray_upside_down() {
    union() {
        difference() {
            // Main body - Note the expanded Y-min side wall
            translate([case_min_x - wall_thickness, case_min_y - side_wall_t, 0])
            cube([case_width + front_extension + wall_thickness, case_length + side_wall_t + wall_thickness, total_internal_height + base_thickness]);

            // Internal cavity (Remains tight to PCB)
            translate([case_min_x, case_min_y, base_thickness])
            cube([case_width + front_extension + 20, case_length, total_internal_height + 1]);

            // USB Cutout (Front Wall at case_min_x)
            translate([case_min_x, usb_in_y_flipped, usb_z])
            rotate([90, 0, -90])
            pill(11.0, 5.0, 20);

            // --- FLEX TAB CAVITY (Hidden pocket inside the thick wall) ---
            // Leaves a solid 1.2mm wall next to PCB, creates a 2.0mm void for flexing, leaves 1.8mm for the tab itself
            translate([tab_start_x, case_min_y - side_wall_t + 1.8, -0.1])
            cube([tab_l + slit_w + 1, 2.0, total_internal_height + base_thickness + 0.2]);

            // --- FLEX TAB SLITS ---
            // Front vertical slit (frees the tip of the tab)
            translate([tab_start_x, case_min_y - side_wall_t - 0.1, -0.1])
            cube([slit_w, 1.8 + 2.0 + 0.2, total_internal_height + base_thickness + 0.2]);

            // Bottom horizontal slit (disconnects the tab from the floor)
            translate([tab_start_x, case_min_y - side_wall_t - 0.1, -0.1])
            cube([tab_l + slit_w, 1.8 + 0.2, base_thickness + 0.2]);
        }

        // --- OUTWARD LOCKING TAB WEDGE ---
        // Attached to the outside face of the flex arm
        translate([tab_start_x + slit_w, case_min_y - side_wall_t + 0.1, base_thickness])
        linear_extrude(height=total_internal_height)
        polygon([
            [0, 0],                 // Tip base
            [0, -tab_protrusion],   // Flat locking face
            [4, -tab_protrusion],   // Flat top
            [tab_l, 0]              // Ramp sloping back towards hinge (+X)
        ]);

        // PCB Standoffs
        translate([0, board_center_y, 0])
        mirror([0, 1, 0])
        translate([0, -board_center_y, 0])
        union() {
            standoff(h1);
            standoff(h2);
            standoff(h3);
            standoff(h4);
        }
    }
}

module tray_outline(tolerance = 0.2) {
    translate([
        case_min_x - wall_thickness - tolerance,
        case_min_y - side_wall_t - tolerance,
        -tolerance
    ])
    cube([
        case_width + front_extension + wall_thickness + (tolerance * 2),
         case_length + side_wall_t + wall_thickness + (tolerance * 2),
         total_internal_height + base_thickness + (tolerance * 2) + 0.75
    ]);
}

module receiver_pocket_cutout(tolerance = 0.2) {
    // 1. Cut the main channel using the updated, asymmetric outline
    tray_outline(tolerance);

    // 2. Cut the locking cavity for the wedge to snap into
    translate([
        tab_start_x - tolerance,
        case_min_y - side_wall_t - tab_protrusion - tolerance,
        base_thickness - tolerance
    ])
    cube([
        tab_l + slit_w + (2*tolerance),
         tab_protrusion + tolerance + 0.1,
         total_internal_height + 2*tolerance
    ]);

    // 3. Drill an extended 2.5mm hole for the release tool (points +Y)
    translate([
        tab_start_x + slit_w + 2,
        case_min_y - side_wall_t - 100,
        base_thickness + total_internal_height/2
    ])
    rotate([-90, 0, 0])
    cylinder(d=2.5, h=120, $fn=20);
}

// Render the completed tray
slide_in_tray_upside_down();

// Uncomment the line below to view the negative shape you should subtract from the main case body
//receiver_pocket_cutout(0.2);
