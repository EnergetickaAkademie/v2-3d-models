$fn = 60;

render_mode = 2; // [0:Bottom Tray, 1:Top Lid, 2:Both (Exploded)]

board_w = 87.5;
board_h = 52.5;
board_clearance = 2.0;

usb_top_x = [19.94, 32.64, 45.34, 58.04, 70.74, 83.44];
usb_bot_x = [19.94, 32.64, 45.34, 58.04, 70.74, 83.44];
usb_in_y = 117.35;

h1 = [10.41, 140.21];
h2 = [92.58, 140.34];
h3 = [92.58, 93.98];
h4 = [10.29, 93.85];

board_center_x = (h1[0] + h2[0] + h3[0] + h4[0]) / 4;
board_center_y = (h1[1] + h2[1] + h3[1] + h4[1]) / 4;

case_width = board_w + board_clearance;
case_length = board_h + board_clearance;

case_min_x = board_center_x - (case_width / 2);
case_max_x = board_center_x + (case_width / 2);
case_min_y = board_center_y - (case_length / 2);
case_max_y = board_center_y + (case_length / 2);

wall_thickness = 1.0; 
lid_thickness = 2.0;

base_thickness = 2.0;
standoff_h = 4.0;
pcb_thickness = 1.6;

usb_center_above_pcb = 1.6;
usb_z = base_thickness + standoff_h + pcb_thickness + usb_center_above_pcb;

clearance_above_pcb = 12.0;
total_internal_height = standoff_h + pcb_thickness + clearance_above_pcb;

fit_tolerance = -0.15;
u_slot_w = 11.5;

explode_dist = (render_mode == 2) ? 25 : 0;

hook_w = 10.0;
hook_h = 4.0;
hook_protrusion = 0.4;
tab_x1 = case_min_x + case_width * 0.25;
tab_x2 = case_min_x + case_width * 0.75;

module pill(w, h, depth) {
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module bottom_tray() {
    difference() {
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
        cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height + base_thickness]);

        translate([case_min_x, case_min_y, base_thickness])
        cube([case_width, case_length, total_internal_height + 1]);

        for(x = usb_top_x) translate([x, case_max_y, usb_z]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
        for(x = usb_bot_x) translate([x, case_min_y, usb_z]) rotate([90, 0, 0]) pill(9.5, 3.5, 20);
        translate([case_min_x, usb_in_y, usb_z]) rotate([90, 0, -90]) pill(9.5, 3.5, 20);

        pocket_z = base_thickness + total_internal_height - 4;
        
        for(tx = [tab_x1, tab_x2]) {
            translate([tx, case_min_y, pocket_z])
            hull() {
                translate([-(hook_w+1)/2, 0, -0.2]) cube([hook_w+1, 0.01, hook_h + 0.4]);
                translate([-(hook_w+1)/2, -hook_protrusion - 0.1, 0.8]) cube([hook_w+1, 0.01, hook_h - 1.6]);
            }
            translate([tx, case_min_y, base_thickness + total_internal_height])
            hull() {
                translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, -hook_protrusion - 0.1, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, 0, hook_protrusion + 0.1]) cube([hook_w+1, 0.01, 0.1]);
            }

            translate([tx, case_max_y, pocket_z])
            hull() {
                translate([-(hook_w+1)/2, 0, -0.2]) cube([hook_w+1, 0.01, hook_h + 0.4]);
                translate([-(hook_w+1)/2, hook_protrusion + 0.1, 0.8]) cube([hook_w+1, 0.01, hook_h - 1.6]);
            }
            translate([tx, case_max_y, base_thickness + total_internal_height])
            hull() {
                translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, hook_protrusion + 0.1, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, 0, hook_protrusion + 0.1]) cube([hook_w+1, 0.01, 0.1]);
            }
        }
    }

    standoff(h1);
    standoff(h2);
    standoff(h3);
    standoff(h4);
}

module top_lid() {
    tol = 0.4;
    
    b_main_w = 23.368 + tol;
    b_main_l = 39.192 + tol;
    b_prot_w = 36.716 + tol;
    b_prot_l = 15.198 + tol;
    
    white_pole_r = 3.0 + (tol / 2);
    green_pole_r = 2.5 + (tol / 2);
    
    pole_spacing_x = 37.882 / 2;
    
    _y_offs = 15;
    pole_y_offsets = [0 + _y_offs, -14.586 + _y_offs, -28.365 + _y_offs]; 
    
    dist_to_first_pole = 13.788;
    b_edge_x = 23.368 / 2;
    first_pole_x = b_edge_x + dist_to_first_pole;
    
    socket_depth = 1.0;
    
    assembly_offset_x = board_center_x - 25; 
    assembly_offset_y = board_center_y;

    translate([0, 0, base_thickness + total_internal_height + explode_dist])
    difference() {
        union() {
            translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
            cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, lid_thickness]);

            translate([case_min_x + fit_tolerance, case_min_y + fit_tolerance, -5])
            difference() {
                cube([case_width - 2*fit_tolerance, case_length - 2*fit_tolerance, 5]);
                translate([wall_thickness, wall_thickness, -1])
                cube([case_width - 2*fit_tolerance - 2*wall_thickness, case_length - 2*fit_tolerance - 2*wall_thickness, 7]);
            }

            for(tx = [tab_x1, tab_x2]) {
                translate([tx, case_min_y + fit_tolerance, -4])
                hull() {
                    translate([-hook_w/2, 0, 0]) cube([hook_w, 0.01, hook_h]);
                    translate([-hook_w/2, -hook_protrusion, 1]) cube([hook_w, 0.01, hook_h-2]);
                }
                translate([tx, case_max_y - fit_tolerance, -4])
                hull() {
                    translate([-hook_w/2, 0, 0]) cube([hook_w, 0.01, hook_h]);
                    translate([-hook_w/2, hook_protrusion, 1]) cube([hook_w, 0.01, hook_h-2]);
                }
            }

            tab_drop = total_internal_height + base_thickness - usb_z;
            clamp_depth = 4.0;

            for(x = usb_top_x) {
                translate([x - u_slot_w/2, case_max_y - clamp_depth, -tab_drop])
                cube([u_slot_w, clamp_depth, tab_drop]);
            }
            for(x = usb_bot_x) {
                translate([x - u_slot_w/2, case_min_y, -tab_drop])
                cube([u_slot_w, clamp_depth, tab_drop]);
            }
            translate([case_min_x, usb_in_y - u_slot_w/2, -tab_drop])
            cube([clamp_depth, u_slot_w, tab_drop]);
        }

        tab_z_local = -(total_internal_height + base_thickness - usb_z);

        for(x = usb_top_x) translate([x, case_max_y, tab_z_local]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
        for(x = usb_bot_x) translate([x, case_min_y, tab_z_local]) rotate([90, 0, 0]) pill(9.5, 3.5, 20);
        translate([case_min_x, usb_in_y, tab_z_local]) rotate([90, 0, -90]) pill(9.5, 3.5, 20);
        
        translate([assembly_offset_x, assembly_offset_y, lid_thickness - socket_depth])
        union() {
            translate([-b_main_w/2, -b_main_l/2, 0])
            cube([b_main_w, b_main_l, socket_depth + 1]);
            
            translate([-b_prot_w/2, -b_prot_l/2, 0])
            cube([b_prot_w, b_prot_l, socket_depth + 1]);
            
            pole_center_x = first_pole_x + pole_spacing_x;
            pole_center_y = pole_y_offsets[1];
            
            translate([pole_center_x, pole_center_y, 0])
            rotate([0, 0, 180])
            translate([-pole_center_x, -pole_center_y, 0])
            for (col = [0:2]) {
                for (row = [0:2]) {
                    px = first_pole_x + (col * pole_spacing_x);
                    py = pole_y_offsets[row];
                    current_r = (row == 0) ? white_pole_r : green_pole_r;
                    
                    translate([px, py, 0])
                    cylinder(r=current_r, h=socket_depth + 1, $fn=32);
                }
            }
        }
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