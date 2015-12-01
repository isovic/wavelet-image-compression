
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name wavelet -dir "/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet/planAhead_run_1" -part xc6slx45fgg676-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet/ramfile.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet} }
set_property target_constrs_file "ramfile.ucf" [current_fileset -constrset]
add_files [list {ramfile.ucf}] -fileset [get_property constrset [current_run]]
link_design
