## Wrap the trajectories

proc wrapTraj {} {

    qwrap center "fragment 0"  
    
    if [file isdirectory traj] {
      set fname [file tail\
        [lindex [molinfo top get filename] 0 1]]
      animate write dcd ./traj/$fname
    }
}

after idle {wrapTraj}
quit
