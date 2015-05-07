cat ../../../Expeditions/imma/Adventure_1773-4.imma > tmp.imma
cat  ../../../Expeditions/imma/Aurora_1914-16.imma >> tmp.imma
cat  ../../../Expeditions/imma/Beagle_1831-6.imma >> tmp.imma
cat  ../../../Expeditions/imma/Boussole_1785-88.imma >> tmp.imma
cat  ../../../Expeditions/imma/Discovery_1776-9.imma >> tmp.imma
cat  ../../../Expeditions/imma/Discovery_1776-9_b.imma >> tmp.imma
cat  ../../../Expeditions/imma/Dorothea_1818.imma >> tmp.imma
cat  ../../../Expeditions/imma/Emma+Yelcho_1916.imma >> tmp.imma
cat  ../../../Expeditions/imma/Endurance_1914-16.imma >> tmp.imma
cat  ../../../Expeditions/imma/Favorite_1830-2.imma >> tmp.imma
cat  ../../../Expeditions/imma/First_Fleet_1787-8.imma >> tmp.imma
cat  ../../../Expeditions/imma/Fury_1824-5.imma >> tmp.imma
cat  ../../../Expeditions/imma/Hecla_1819-20.imma >> tmp.imma
cat  ../../../Expeditions/imma/Hecla_1821-3.imma >> tmp.imma
cat  ../../../Expeditions/imma/Hecla_1824-5.imma >> tmp.imma
cat  ../../../Expeditions/imma/Isabella_1818.imma >> tmp.imma
cat  ../../../Expeditions/imma/James_Caird_1916.imma >> tmp.imma
cat  ../../../Expeditions/imma/Paramore_1699-1700.imma >> tmp.imma
cat  ../../../Expeditions/imma/Princess_Louise_1849.imma >> tmp.imma
cat  ../../../Expeditions/imma/Resolution_1779-80.imma >> tmp.imma
cat  ../../../Expeditions/imma/Resolution_1779-80_b.imma >> tmp.imma
cat  ../../../Expeditions/imma/Resolution_W1_1772-4.imma >> tmp.imma
cat  ../../../Expeditions/imma/Resolution_W2_1772-4.imma >> tmp.imma
cat  ../../../Expeditions/imma/Scoresby_1807-18.imma >> tmp.imma
cat  ../../../Expeditions/imma/Scoresby_1822.imma >> tmp.imma
cat  ../../../Expeditions/imma/Scotia_1902-3.imma >> tmp.imma
cat  ../../../Expeditions/imma/Scotia_1903-4.imma >> tmp.imma
cat  ../../../Expeditions/imma/Vincennes_1838-42.imma >> tmp.imma
cat  ../../../Expeditions/imma/discovery_1791-5.imma >> tmp.imma
cat  ../../../Expeditions/imma/resolution_C_1772-5.imma >> tmp.imma
cat  ../../../Expeditions/imma/scoresby_1810-17.imma >> tmp.imma
# Cut off all but the core attachment (otherwise R IMMA module gets confused)
mv tmp.imma tmp2.imma
cut -c1-108 < tmp2.imma > tmp.imma
rm tmp2.imma

