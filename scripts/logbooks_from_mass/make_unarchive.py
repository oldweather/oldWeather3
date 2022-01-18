#!/usr/bin/python

# Extract and unpack selected logbook images from MASS

import csv
import re
import warnings
import os

# Get the Moose directory listings
with open('ls_images_new','r') as f:
    archived = [line.rstrip() for line in f.readlines()]

moo_f = open('to_retrieve.txt','w')
miss_f = open('missing.txt','w')

# Get the list of logbooks Clive has selected
with open('SA_logs_Inventory.csv','r') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    next(csv_reader) # discard the headers
    for row in csv_reader:
        ref = row[12]
        ref=ref.strip()
        if len(ref)==0 : continue
        # convert to a regexp - names don't always match exactly
        ref=ref.replace('/','_')
        ref=ref.replace('ADM53','ADM.*53')
        ref=ref.replace('_','[/\s\._\-]')
        ref=ref.replace(' ','[/\s\._\-]')
        ref=ref.replace('&','+')
        ref=ref.replace('+','\+')
        # Find the archived file that matches
        r = re.compile(ref+".*\.tgz")
        matched=False
        for line in archived:
            if r.search(os.path.basename(line)) is not None:
                print(ref+" - "+line)
                moo_f.write("%s\n" % line)
                matched=True
                continue
        if matched == False:
            print("Failed "+ref)
            miss_f.write("%s\n" % row[12])

moo_f.close()
miss_f.close()
        
        
