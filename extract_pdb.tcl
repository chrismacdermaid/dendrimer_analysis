## Wrap the trajectories

proc wrapTraj {{molid top}} {

    lassign $::argv gen 

    set sel [atomselect $molid "fragment 0"] 
    set n [expr {[molinfo $molid get numframes] - 1}]

    if [file isdirectory dtraj] {
      set fname [file rootname [file tail\
        [lindex [molinfo $molid get filename] 0 1]]]
      
        animate write pdb ./pdbs/$gen\.pdb beg $n sel $sel 
    }

    $sel delete
}

after idle {wrapTraj}
quit
