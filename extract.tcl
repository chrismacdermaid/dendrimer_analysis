## Wrap the trajectories

proc wrapTraj {{molid top}} {

    qwrap center "fragment 0"  
  
    set sel [atomselect $molid "fragment 0"] 

    if [file isdirectory dtraj] {
      set fname [file tail\
        [lindex [molinfo top get filename] 0 1]]
      animate write psf ./dtraj/$fname.psf sel $sel 
      animate write dcd ./dtraj/$fname sel $sel 
    }

    $sel delete
}

after idle {wrapTraj}
quit
