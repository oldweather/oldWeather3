moo mkdir  moose:/adhoc/users/philip.brohan/logbook_images/Clive_Royal_Society/ 
cd "/scratch/hadpb/logbook_images/2019_11_Met_Office_Delivery/Royal_Society_Met_Obs_1774_1826"
mkdir -p  /var/tmp/RtmpHqA222 
tar -czf "/var/tmp/RtmpHqA222/Royal_Society_Met_Obs_1774_1826.contents.tgz" --no-recursion *.* 
moo put  /var/tmp/RtmpHqA222/Royal_Society_Met_Obs_1774_1826.contents.tgz moose:/adhoc/users/philip.brohan/logbook_images/Clive_Royal_Society/ 
rm -r  /var/tmp/RtmpHqA222 
 
