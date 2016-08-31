#!/usr/bin/env python
# coding: utf-8

import MDAnalysis
import numpy as np
import matplotlib.pyplot as plt
import sys
import math
import os.path

from MDAnalysis.analysis.density import density_from_Universe
def pbcMinMax(u):

    box = [] 
    for ts in u.trajectory:
        box.append(ts.dimensions)

    return np.array(box).max(axis=0)

def histogram2D(label,PSF,DCD):

    prefix = os.path.basename(PSF).split(".")[0]
    prefix = prefix.split()[0]

    #atomtypes = ['COOH','OAB', 'SER', 'SER']  
    #resnames  = ['EDH','PIP','CMP','AMP','NH2','AZZ','AHH']
    resnames = ['WAT']

    ## Load PSF and DCD files  
    u = MDAnalysis.Universe(PSF,DCD)

    ## Get the maximum dimensions over the 
    ## course of the trajectory
    a,b,c,alpha,beta,gamma = pbcMinMax(u)
    cover2 = c/2.0
    dz = 800.00 

    ## Residue head groups
    if True:
        for rn in resnames: 
            for z in np.arange(-cover2,cover2,dz):

                ass = "resname %s" % rn 
                file_string = "./density/%s_%s.dx" % (prefix,rn)

                sel = u.select_atoms(ass)

                if sel.n_atoms != 0: 
                    D = density_from_Universe(u,delta=2.0,
                            atomselection=ass)
  
                    #D.convert_density('nm^{-3}') 

                    D.export(file_string)

        ## Water
        #D = density_from_Universe(u,delta=10.0,
        #        atomselection='type W')
        #D.convert_density('TIP3P')
        #D.export(prefix+'_WAT.dx')

        ## Everything
        D = density_from_Universe(u,delta=2.0,
                atomselection='all')
        D.export('./density/'+prefix+'_ALL.dx')

if __name__ == '__main__':
    histogram2D(sys.argv[1],sys.argv[2],sys.argv[3:])
