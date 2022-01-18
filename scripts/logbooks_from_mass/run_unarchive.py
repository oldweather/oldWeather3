#!/usr/bin/env python

# Retrieve the selected list of logs from MASS

import os
import os.path
import subprocess
import tarfile

# location of images on disc
disc_root='/scratch/hadpb/logbook_images/retrieved_SA'

with open('extra_retrieve.txt','r') as f:
    archived = [line.rstrip() for line in f.readlines()]

for tf in archived:

    # directory to retrieve to
    rdir = "%s/%s" % (disc_root,os.path.dirname(tf[48:]))
    if not os.path.isdir(rdir):
        os.makedirs(rdir)
    if os.path.exists("%s/%s" % (rdir,os.path.basename(tf))):
        continue

    # Retrieve ob file from MASS
    proc = subprocess.Popen("moo get %s %s" % 
                                              (tf,rdir),
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               shell=True)
    (out, err) = proc.communicate()
    if len(err)!=0:
        print(err)
        raise Exception("Failed to retrieve %s" % tf)
 
