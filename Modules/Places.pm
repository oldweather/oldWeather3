# Estimate lat and long from a port/place name

package Places;

use strict;
use warnings;
use Carp;
use String::Approx 'amatch';
use Data::Dumper;
@Places::ISA       = ('Exporter');
@Places::EXPORT_OK = qw(EstimateLLfromName);

my @PortLocations;    # Store the Port positions data
my $isLoaded = 0;

# load the port locations on first access
sub _load {
    while (<DATA>) {
        chomp;
        $_ =~ s/\#.*$//;    # Strip comments
        my @Fields = split /\t/, $_;
        $Fields[0] =~ s/\s+$//;    # Strip trailing whitespace from name
        $Fields[0] = lc( $Fields[0] );
        push @PortLocations, [@Fields];
    }
    $isLoaded = 1;
}

sub EstimateLLfromName {
    my $Name         = shift;
    my $LatGuess     = shift;
    my $LatPrecision = shift;
    my $LonGuess     = shift;
    my $LonPrecision = shift;

    unless ( $isLoaded == 1 ) { _load(); }

    $Name = lc($Name);
    $Name =~ s/[^a-z ]//g;
    $Name =~ s/^\s+//;
    $Name =~ s/\s+$//;
    $Name  =~ s/bearing//g;
    unless ( $Name =~ /\w\w+/ ) { return; }
    my %Duds = (
        'no information' => 1,
        'on patrol'      => 1,
        'cant read'      => 1,
        'base'           => 1,
        'patrol'         => 1,
        'none given'     => 1,
        'no details'     => 1,
        'port unknown'   => 1,
        'port unlisted'  => 1,
        'arctic ocean'   => 1,
    );
    if ( exists( $Duds{$Name} ) ) { return; }

    my @ShortList;
    foreach my $Location (@PortLocations) {
        if (   ( $LatGuess + $LatPrecision ) > $Location->[2]
            && ( $LatGuess - $LatPrecision ) < $Location->[2]
            && ( $LonGuess + $LonPrecision ) > $Location->[1]
            && ( $LonGuess - $LonPrecision ) < $Location->[1]
            && scalar( amatch( $Location->[0], ($Name) ) ) > 0 )
        {
            push @ShortList, $Location;
            if ( scalar(@ShortList) > 10 ) { return; }
        }
    }
    @ShortList = sort { length( $b->[0] ) <=> length( $a->[0] ) } @ShortList;
    return (@ShortList);
}

1;

## Port positions by name
__DATA__
DEVONPORT                	  -4.2	  50.4
DEVONPORT                	 174.8	 -36.8
PORTSMOUTH               	  -1.1	  50.8
HONG KONG                	 114.2	  22.3
SCAPA FLOW               	  -3.1	  58.9
TRINCOMALEE              	  81.2	   8.6
GREENOCK                 	  -4.8	  55.9
ROSYTH                   	  -3.4	  56.0
SIMONSTOWN               	  18.4	 -34.2
COLOMBO                  	  79.8	   6.9
ALEXANDRIA               	  29.9	  31.2
MALTA                    	  14.4	  35.9
CHATHAM                  	   0.5	  51.4
DURBAN                   	  31.0	 -29.9
SINGAPORE                	 103.9	   1.3
FREETOWN                 	 -13.2	   8.5
GIBRALTAR                	  -5.3	  36.1
LIVERPOOL                	  -3.0	  53.4
SCAPA                    	  -3.1	  58.9
SYDNEY                   	 151.2	 -33.9
KILINDINI                	  39.8	  -5.0
BOMBAY                   	  72.8	  19.0
PORTLAND                 	  -2.4	  50.5
WEI HAI WEI              	 122.1	  37.5
BERMUDA                  	 -64.8	  32.3
ADEN                     	  45.0	  12.8
HALIFAX                  	 -63.6	  44.6
BELFAST                  	  -6.0	  54.6
SHANGHAI                 	 121.5	  31.2
HVALFJORD                	 -21.7	  64.4
NORFOLK                  	 -76.3	  36.8
PLYMOUTH                 	  -4.1	  50.4
HEBBURN                  	  -1.5	  55.0
BOSTON                   	 -71.1	  42.4
GARELOCH                 	  -4.8	  56.0
MOMBASA                  	  39.2	  -6.2
ROTHESAY                 	  -5.1	  55.8
SHEERNESS                	   0.8	  51.4
SOUTHAMPTON              	  -1.4	  50.9
DUNDEE                   	  -3.0	  56.5
AMOY                     	 118.1	  24.5
PORT SAID                	  32.3	  31.3
PHILADELPHIA             	 -75.2	  40.0
GLASGOW                  	  -4.2	  55.8
AUCKLAND                 	 174.8	 -36.9
NEW YORK                 	 -74.0	  40.7
HOLY LOCH                	  -4.9	  56.0
CHARLESTON               	 -79.9	  32.8
SINGAPORE NAVAL BASE     	 103.9	   1.3
CAPETOWN                 	  18.4	 -33.9
HVALFJORDUR              	 -23.1	  66.1
FREMANTLE                	 115.8	 -32.0
COCHIN                   	  76.2	  10.0
SWATOW                   	 116.7	  23.4
PORT ELIZABETH           	  25.6	 -34.0
ALGIERS                  	   3.1	  36.8
VANCOUVER                	-123.1	  49.2
BAHRAIN                  	  50.5	  26.0
NEWPORT NEWS             	 -76.4	  37.0
SUEZ                     	  32.5	  30.0
TSINGTAO                 	 120.3	  36.1
CLYDE                    	  -4.2	  55.8
BROOKLYN                 	 -74.0	  40.6
MANUS                    	 143.6	  -1.3
KIUKIANG                 	 113.0	  22.8
HANKOW                   	 114.3	  30.6
YOKOHAMA                 	 139.7	  35.5
ESQUIMALT                	-123.4	  48.4
BAHREIN                  	  50.5	  26.0
MARE ISLAND              	-122.3	  38.1
LAMLASH                  	  -5.2	  55.5
GOVAN                    	  -4.3	  55.9
ROYAL ALBERT DOCKS       	  -0.1	  51.5
PENANG                   	 100.3	   5.4
SPITHEAD                 	  -1.1	  50.8
INVERGORDON              	  -4.2	  57.7
TARANTO                  	  17.2	  40.6
DIEGO SUAREZ             	  49.3	 -12.3
LOCH STRIVEN             	  -5.1	  56.0
LOCH ALSH                	  -5.7	  57.2
TRINCOMALI               	  81.2	   8.6
LONDONDERRY              	  -7.2	  55.0
BASRAH                   	  47.8	  30.5
HAIFA                    	  35.0	  32.8
BIRKENHEAD               	  -3.0	  53.4
BREMERTON                	-122.6	  47.6
GARELOCK                 	  -4.8	  56.0
ZARA                     	  15.2	  44.1
ST JOHN                  	 -55.1	  49.3
PORT SUDAN               	  37.2	  19.6
SEYCHELLES               	  55.7	  -4.6
FREETOWN S L             	 -13.2	   8.5
NO 10 DOCK               	  -1.1	  50.8
TRINCO                   	  81.2	   8.6
SAN DIEGO                	-117.2	  32.7
BEIRUT                   	  35.5	  33.9
MASSAWA                  	  39.5	  15.6
SIMONS TOWN              	  18.4	 -34.2
WEIHAIWEI                	 122.1	  37.5
HEBBURN ON TYNE          	  -1.5	  55.0
LEYTE                    	 124.5	  11.4
MANILA                   	 121.0	  14.6
BALTIMORE                	 -76.6	  39.3
METHIL                   	  -3.0	  56.2
KURE                     	 132.6	  34.2
SOUTH SHIELDS            	  -1.4	  55.0
PERSIAN GULF             	  51.0	  27.0
NO 5 BASIN               	  -1.1	  50.8
EAST LONDON              	  27.9	 -33.0
BANDAR ABBAS             	  56.3	  27.2
VALETTA                  	  14.5	  35.9
SAN FRANCISCO            	-122.4	  37.8
MOTHER BANK              	  -1.1	  50.8
PORT OF SPAIN            	 -61.5	  10.7
KHOR KUWAI               	  56.4	  26.4
FASLANE                  	  -4.8	  56.0
KHOR KALIYA              	  50.6	  26.2
ROYAL ALBERT DOCK        	  -0.1	  51.5
BRISBANE                 	 153.0	 -27.5
CLYDEBANK                	  -4.4	  55.9
KINGSTON                 	 -76.8	  18.0
CHEFOO                   	 121.4	  37.5
TOKYO BAY                	 139.8	  35.4
MELBOURNE                	 145.0	 -37.8
PORT STANLEY             	 -57.9	 -51.7
TROON                    	  -4.7	  55.5
TYNE                     	  -1.5	  55.0
HEI HAI HEI              	 122.1	  37.5
MAURITIUS                	  57.6	 -20.3
TAIL OF THE BANK         	  -4.8	  55.9
WEYMOUTH BAY             	  -2.5	  50.6
NORTH SHIELDS            	  -1.5	  55.0
JERVIS BAY               	 150.8	 -35.1
DALMUIR                  	  -4.4	  55.9
NAVAL BASE SINGAPORE     	 103.9	   1.3
MASIRA                   	  58.7	  20.5
WELLINGTON               	 174.8	 -41.3
TORBAY                   	  -3.5	  50.4
BATAVIA                  	 106.8	  -6.2
AUGUSTA                  	  15.2	  37.2
RIO DE JANEIRO           	 -43.2	 -22.9
ARROMANCHES              	  -0.6	  49.3
MONTEVIDEO               	 -56.2	 -34.9
BANGOR BAY               	  -5.7	  54.7
LAGOS                    	   3.4	   6.5
US NAVY YARD BROOKLY     	 -73.9	  40.7
TRINIDAD                 	 -61.5	  10.7
SAN PEDRO BAY            	 122.3	  12.5
ROSENEATH                	  -4.8	  56.0
PALMA                    	   2.6	  39.6
BASRA                    	  47.9	  30.5
LARNE                    	  -5.8	  54.9
BARROW                   	  -3.2	  54.1
TIENTSIM                 	 117.2	  39.1
MIDDLE DOCK, SOUTH S     	  -1.4	  55.0
ABADAN                   	  48.8	  30.2
DALMUIR BASIN            	  -4.4	  55.9
ROTHESAY BAY             	  -5.1	  55.8
MADRAS                   	  80.2	  13.0
MOBILE                   	 -88.0	  30.7
NORTH WOOLWICH           	   0.1	  51.5
FALMOUTH                 	  -5.1	  50.1
CHARLESTON SC            	 -79.9	  32.8
CARDIFF                  	  -3.2	  51.5
AKUREYRI                 	 -18.1	  65.7
DAKAR                    	 -17.4	  14.7
TAIL OF BANK             	  -4.8	  56.0
REYKJAVIK                	 -21.9	  64.1
PEARL HARBOUR            	-158.0	  21.3
CALCUTTA                 	  88.4	  22.5
MOTHERBANK               	  -1.1	  50.8
GRAND HARBOUR            	  14.5	  35.9
KARACHI                  	  67.0	  24.9
JOHORE                   	 103.5	   2.0
CHINWANGTAO              	 119.6	  39.9
NORTH WOOLWICK           	   0.1	  51.5
SINGAPORE ROADS          	 103.8	   1.3
KOBE                     	 135.1	  34.7
MIDDLE DOCK SOUTH SH     	  -1.4	  55.0
KOLA INLET               	  33.5	  69.2
PORT T                   	  32.6	  29.9
MANZA BAY                	  39.1	  -5.0
RANGOON                  	  96.2	  16.8
EL BUOY                  	 -70.2	  19.6
SINGAPORE BASE           	 103.8	   1.4
NAPLES                   	  14.4	  40.9
SUVA                     	 178.4	 -18.1
TRISTAN DA CUNHA         	 -12.3	 -37.1
MONTE VIDEO              	 -56.2	 -34.9
SIMONS BAY               	  18.4	 -34.2
GARE LOCH                	  -4.8	  56.0
GAVELOCH                 	  -4.8	  56.0
LOWESTOFT                	   1.8	  52.5
BLYTH                    	  -1.5	  55.1
PORTSMOUTH VA            	 -76.3	  36.8
HOBART                   	 147.3	 -42.9
SAIGON                   	 106.7	  10.8
BUENOS AIRES             	 -58.7	 -34.6
GARELOCHHEAD             	  -4.8	  56.1
MIRS BAY                 	 114.4	  22.6
BAHIA                    	 -38.5	 -13.0
CAPE TOWN                	  18.4	 -33.9
SALDANHA BAY             	  18.0	 -33.1
BARRY DOCK               	  -3.2	  51.4
PLYMOUTH SOUND           	  -4.2	  50.3
COCKATOO IS              	 152.5	 -32.2
SAINT JOHN               	 -52.7	  47.5
VAENGA BAY               	  33.4	  69.1
TANGKU                   	 117.6	  39.0
NOUMEA                   	 166.4	 -22.3
MANUS ISLAND             	 147.0	  -2.1
TIEUTSIU                 	 117.2	  39.1
ALEXANDRA DOCK           	  -3.0	  53.4
GIBRALTER                	  -5.3	  36.1
PORT VICTORIA            	  55.5	  -4.6
JESSELTON                	 116.2	   6.0
MERS EL KEBIR            	  -0.7	  35.7
GASPORT                  	  -1.1	  50.8
MUSCAT                   	  58.6	  23.6
HAMPTON ROADS            	 -76.3	  37.0
PORT TEWFICK             	  32.6	  29.9
BELFAST LOUGH            	  -5.6	  54.7
RN BASE SINGAPORE        	 103.8	   1.4
TAMATAVE                 	  49.4	 -18.2
BALBOA                   	 -79.6	   8.9
LONDON                   	  -0.1	  51.5
CHESAPEAKE BAY           	 -76.0	  37.0
NANKING                  	 118.8	  32.1
ADDU ATOLL               	  73.2	  -0.6
PORT TENFIK              	  32.6	  29.9
TAKORADI                 	  -1.8	   4.9
NO 2 DOCK ROSYTH         	  -3.4	  56.0
MARSAXLOKK               	  14.5	  35.8
BANDAR ABBAS PG          	  56.3	  27.2
KUWAIT                   	  47.8	  29.5
ROBINS DRY DOCK          	 -74.0	  40.7
ARGOSTOLI                	  20.5	  38.2
SIERRA LEONE             	 -13.2	   8.5
DAR ES SALAAM            	  39.3	  -6.8
HEBBUAR ON TYNE          	  -1.5	  55.0
STATEN ISLAND            	 -74.2	  40.6
SEYDISFJORD              	 -13.8	  65.3
KAVALLA                  	  24.5	  41.0
FALKLAND ISLANDS         	 -57.9	 -51.7
NAVARIN                  	   5.8	  36.1
FORT BLOCKHOUSE          	  -1.1	  50.8
PORT SWETTENHAM          	 101.4	   3.0
FREEMANTLE               	 115.8	 -32.0
HELENSBURGH              	  -4.7	  56.0
KAMARAN                  	  42.6	  15.3
MERSING                  	 103.8	   2.4
WEYMOUTH                 	  -2.5	  50.6
CORFU                    	  19.8	  39.7
SUDA BAY                 	  24.2	  35.5
ARROCHAR                 	  -4.7	  56.2
AUCHLAND                 	 174.8	 -36.9
TRIESTE                  	  13.8	  45.7
ZANZIBAR                 	  39.2	  -6.2
NORMANDY BEACHEAD        	  -0.9	  49.4
BERBERA                  	  45.0	  10.4
TSUIGTAO                 	 120.3	  36.1
TORQUAY                  	  -3.5	  50.5
SALERNO BAY              	  14.8	  40.7
PORT T.                  	  32.6	  29.9
BARBADOS                 	 -59.6	  13.1
TANJONG PRIOK            	 106.9	  -6.1
ESQUINALT                	-123.4	  48.4
TSING TAO                	 120.3	  36.1
KING GEORGE V DOCKS      	   0.1	  51.5
SANDAKAN                 	 118.0	   5.8
KAMES BAY                	  -5.1	  55.9
6 & 7 WHARF DEVONPOR     	  -4.2	  50.4
BATHURST                 	 -16.6	  13.5
GRAND PORT               	  57.8	 -20.4
MERCURY BAY              	 175.8	 -36.8
KOWLOON                  	 114.2	  22.3
MILFORD HAVEN            	  -5.1	  51.7
PUNTA DEL ESTE           	 -79.1	   8.4
PRINCES DOCK             	  -3.0	  53.4
MORSE D DOCK             	 -74.0	  40.7
SUEZ CANAL               	  32.5	  29.9
BANDAR SHAPUR            	  49.1	  30.4
DALMUIO                  	  -4.4	  55.9
DUNGUN                   	 103.4	   4.8
JOHORE NAVAL BASE        	 103.5	   2.0
SOURABAYA                	 112.8	  -7.2
NW HONG KONG             	 114.1	  22.3
KING GEORGE V            	   0.1	  51.5
NO 17 BUOY ROSYTH        	  -3.4	  56.0
C1 BUOY PORTLAND         	  -2.4	  50.5
NO 10 DOCK DEVONPORT     	  -4.2	  50.4
HARWICH                  	   1.3	  52.0
TEWFICK                  	  32.6	  29.9
BIZERTA                  	   9.9	  37.3
RECIFE                   	 -34.9	  -8.1
MANAPAM                  	  79.1	   9.3
CAMPBELTOWN              	  -5.6	  55.4
ARROMANCHER              	  -0.6	  49.3
PORTSMOUTH NW            	  -1.1	  50.8
GREAT MERCURY ISLAND     	 175.8	 -36.6
PORTSMOUTH NO 15 DOC     	  -1.1	  50.8
TOBERMORY                	  -6.1	  56.6
ST HELENA                	  -5.7	 -15.9
MONTREAL                 	 -73.6	  45.5
WHANGAREI HEADS          	 174.5	 -35.8
KING GEORGE V DOCK       	   0.1	  51.5
ALGER                    	   3.1	  36.8
NAGLE COVE               	 175.3	 -36.1
NORMANDY                 	   0.0	  49.0
BANDA ABBAS              	  56.3	  27.2
NASSAU                   	 -77.3	  25.1
PORT DICKSON             	 101.8	   2.5
PORT CASTRIES            	 -61.0	  14.0
COPENHAGEN               	  12.6	  55.7
LOURENCO MARQUES         	  32.6	 -26.0
MALTA                    	  14.5	  35.9
LOCH ERIBOLL             	  -4.7	  58.5
B I  PORTSMOUTH          	  -1.1	  50.8
ST KILTS                 	 -62.7	  17.3
PORT TEWFIK              	  32.6	  29.9
URMSTON ROAD             	 113.9	  22.3
GRAND HARBOR             	  14.5	  35.9
TAIL O BANK              	  -4.8	  56.0
HENJAM                   	  55.9	  26.7
WEI HEI WEI              	 120.6	  24.3
FREETOWN SL              	 -13.2	   8.5
BALI                     	 115.2	  -8.7
VENICE                   	  12.6	  45.6
K G V DOCK               	   0.1	  51.5
GOSPORT                  	  -1.1	  50.8
LOCK STRIVEN             	  -5.1	  56.0
GOWOCH                   	  -4.8	  56.0
KOMATSUSHIMA             	 134.6	  34.0
CHIN WANG TAO            	 119.5	  39.9
PEARL HARBOUR            	-158.0	  21.3
PORT IBRAHIM             	  32.6	  29.9
TAING TAO                	 120.3	  36.1
KINGSTON JAMAICA         	 -76.8	  18.0
NEWCASTLE ON TYNE        	  -1.6	  55.0
SWAMSEA                  	  -4.0	  51.6
MIAMI                    	 -80.2	  25.8
OBAN                     	  -5.5	  56.4
SUEZ BAY                 	  32.5	  29.9
SFAX                     	  10.8	  34.7
SORRENTO                 	  14.4	  40.6
VALPARAISO               	 -71.6	 -33.0
SERANGOON ANCH           	 103.9	   1.4
SEATTLE                  	-122.3	  47.6
BIRKEN HEAD              	  -3.0	  53.4
TAIL O THE BANK          	  -4.8	  56.0
PASCAGOULA               	 -88.6	  30.4
B I PORTSMOUTH           	  -1.1	  50.8
SERANGOON                	 103.9	   1.4
HOBOKEN                  	 -74.0	  40.7
BI PORTSMOUTH            	  -1.1	  50.8
ORAN                     	  -0.6	  35.7
WUHU                     	 118.3	  31.3
U.S. NAVY YARD BROOK     	 -74.0	  40.6
DURBAN J.A.              	  31.0	 -29.9
BARRY                    	  -3.2	  51.4
ACID BEACH SICILY        	  14.2	  37.1
CAPT COOK DOCK           	 150.6	 -35.1
CASA BLANCA              	  -7.6	  33.5
STORE JETTY SINGAPOR     	 103.8	   1.4
KHOR KAWEI               	  56.4	  26.4
MADEIRA                  	 -16.9	  32.7
ABERDEEN                 	  -2.0	  57.2
DURHAM                   	  -1.8	  54.7
ST LUCIA                 	 -61.0	  13.9
GRASSY BAY               	 -64.8	  32.3
NORTH CORNER JETTY       	  -1.1	  50.8
MITSUHAMA                	 132.7	  33.9
GARELOCH HEAD            	  -4.8	  56.1
LYTTELTON                	 172.7	 -43.6
GRAVESEND BAY            	 -74.0	  40.6
CHANGI                   	 104.0	   1.4
PORT FITZROY             	 175.3	 -36.2
MARSEILLES               	   5.4	  43.3
TAIKOO DOCK              	 114.2	  22.3
KASBA REACH              	  48.5	  30.0
NOCIO BERTH TRINCOMA     	  81.2	   8.6
T I C                    	  -1.5	  55.0
PLOVER COVE              	 114.2	  22.5
PORT BLAIR               	  92.8	  11.7
TYNESIDE                 	  -1.5	  55.0
ROYAL ALBERT DRY DOC     	   0.1	  51.5
CASABLANCA               	  -7.6	  33.5
ATHOL BAY                	 151.2	 -33.9
GARELOCH HD              	  -4.8	  56.1
VALLETTA                 	  14.5	  35.9
LACK STRIVEN             	  -5.1	  56.0
JAMAICA                  	 -76.8	  18.0
KARARCHI                 	  67.0	  24.9
AMAY                     	 118.1	  24.5
MANCHESTER               	  -2.2	  53.5
ULITHI                   	 139.7	  10.0
DEVENPORT                	  -4.2	  50.4
MATADI                   	  13.4	  -5.8
DEAL                     	   1.4	  51.2
ALBERT                   	  -3.0	  53.4
DALMUIR BASIN EAST S     	  -4.4	  55.9
FAO                      	  48.5	  30.0
TIC                      	  -1.5	  55.0
CAEN ROADS               	  -0.3	  49.2
KHU KALIYA               	  48.4	  30.2
SCAPA BAY                	  -3.0	  59.0
SALONIKA                 	  23.0	  40.7
GARLOCH                  	  -4.8	  56.0
LYTTLETON                	 172.7	 -43.6
COMOX                    	-124.9	  49.7
BLOCKHOUSE               	  -1.1	  50.8
TAUGKU                   	 117.6	  39.0
ST JOHNS                 	 -52.7	  47.5
SIMONTOWN                	  18.4	 -34.2
TALCAHUANO               	 -73.1	 -36.7
SAMARANG                 	 111.1	   1.7
LISBON                   	  -9.1	  38.7
ST KITTS                 	 -62.8	  17.3
SCAPA FLOWS              	  -3.1	  58.9
NEW CALEDONIA            	 165.5	 -21.5
BEIRA                    	  33.2	 -18.1
BONE                     	   7.8	  36.9
SWAVOW                   	 116.7	  23.4
IVERGORDON               	  -4.2	  57.7
NO C 3 BERTH TRINCOM     	  81.2	   8.6
TRINCOMALI NO 2 BERT     	  81.2	   8.6
JUNK BAY                 	 114.2	  22.3
WALLSEND ON TYNE         	  -1.6	  55.0
WALVIS BAY               	  14.5	 -22.9
KHASSAB BAY              	  56.2	  26.2
SURABAYA                 	 112.8	  -7.2
SUNDERLAND               	  -1.4	  54.9
N W HONG KONG            	 114.1	  22.3
MANUO                    	 168.6	 -17.7
PALK BAY                 	  79.5	   9.1
CHITTAGONG               	  92.0	  22.0
DEVONPORT NZ             	 174.8	 -36.8
SHUWAMIYA                	  55.9	  17.9
BERGEN                   	   5.3	  60.3
PAHUA                    	-149.3	 -17.7
COLOMBO DRY DOCK         	  79.8	   6.9
SAN TROPEZ               	   6.6	  43.3
GILBRALTAR               	  -5.3	  36.1
MASIRA CHANNEL           	  58.7	  20.5
PONAM                    	 146.9	  -1.9
WALLSEND                 	  -1.6	  55.0
ARDROSSAN                	  -4.8	  55.6
DIEGO GARCIA             	  72.4	  -7.3
LOBITO                   	  13.6	 -12.3
MOVILLE                  	  -7.0	  55.2
MASIRAH                  	  58.8	  20.4
SALDENHA BAY             	  18.0	 -33.1
TACOMA                   	-122.4	  47.3
FALKLAND IS              	 -57.9	 -51.7
CLYDE ANCHORAGE          	  -4.9	  55.9
DUNBAR                   	  -2.5	  56.0
SPETSAI                  	  23.1	  37.3
NB JAHORE                	 103.8	   1.5
HARBOUR GRACE            	 -53.2	  47.7
JARROW SLAKE             	  -1.5	  55.0
HVALFJORDR               	 -21.7	  64.4
HUALFJORDUS              	 -21.7	  64.4
SCOTTS YARD              	  -4.8	  55.9
DAR ES SALAAH            	  39.3	  -6.8
ROSYTH IN NO 1 DOCK      	  -3.4	  56.0
YOKOHANA                 	 139.6	  35.5
9 1 BERTH SCAPA          	  -3.0	  59.0
MYKONI                   	  25.3	  37.5
TRIMCOMALEE              	  81.2	   8.6
LIBREVILLE               	   9.4	   0.4
GUAM                     	 144.7	  13.4
ABUDAN                   	  48.8	  30.2
TOLO INLET               	 114.2	  22.4
TAIL O` THE BANK         	  -4.8	  56.0
GRYTVIKEN                	 -36.5	 -54.3
LIVERPOOL BAY            	  -3.2	  53.5
KENKIANG                 	 119.4	  32.2
GREAT MERCURY I          	 175.9	 -36.6
ABBAZIA                  	  12.5	  45.7
BUSHIRE                  	  50.8	  29.0
LIMASOL                  	  33.0	  34.6
TANGIER                  	  -5.8	  35.8
HVAR                     	  16.7	  43.1
PUERTO MONIT             	 -72.9	 -41.5
NAPIER                   	 176.9	 -39.5
SEEADLER HARBOUR         	 147.3	  -2.0
QUEBEC                   	 -72.0	  47.5
LABUAN                   	 115.2	   5.3
S SHIELDS                	  -1.4	  55.0
YOKOHAMAS                	 139.6	  35.5
GREENOCK FLOATING DO     	  -4.8	  55.9
PORTSMOUTH HARBOUR       	  -1.1	  50.8
NEW ORLEANS              	 -90.1	  30.0
MAYOTTA                  	  45.2	 -12.8
LEONPORT                 	  -4.2	  50.4
DAV ES SALAAM            	  39.3	  -6.8
HORTA                    	 -28.6	  38.5
SKAGEN                   	  15.5	  68.0
NAGASAKI                 	 129.9	  32.8
BARRANQUILLA             	 -74.8	  11.0
SWAFOW                   	 116.7	  23.4
HVALEFORD                	 -21.7	  64.4
DABEI                    	 118.9	  26.9
AJACCIO                  	   8.7	  41.9
NEW BROOKLYN             	 -74.9	  39.7
9 6 BERTH SCAPA          	  -3.0	  59.0
PORT  STANLEY            	 -57.9	 -51.7
HODEIDA                  	  43.2	  14.8
SYDENHAM JETTY           	 174.3	  -0.7
ST  KITTS                	 -62.8	  17.3
WHAUGAPUA BAY            	 175.6	 -36.7
GULF OF SALEMO           	  14.7	  40.5
NUNEA                    	 166.4	 -22.3
MIDDLE DOCK S. SHIEL     	  -1.4	  55.0
ST JOHN`S                	 -52.7	  47.5
KHASAB BAY               	  56.2	  26.2
BRIDGETOWN               	 -59.6	  13.1
ALGIER                   	   3.1	  36.8
MALTA                    	  14.5	  35.9
NO 3 DOCK GOVAN          	  -4.3	  55.9
FIRTH OF CLYDE           	  -5.0	  55.7
PORT TREBUKI             	  24.6	  38.8
TREBUKI                  	  24.6	  38.8
PIRAEUS                  	  23.6	  38.0
PORT JEFFERSON           	 -73.1	  40.9
ADELAIDE                 	 138.6	 -34.9
THE KOLA INLET           	  33.5	  69.2
M S J PORTSMOUTH         	  -1.1	  50.8
PORT SUEZ                	  32.5	  30.0
SINGAPORE ROAD           	 103.8	   1.3
TOLO                     	 114.2	  22.4
INGENIERO WHITE          	 -62.3	 -38.8
DEBAI                    	  55.3	  25.3
ASCENSION                	 -14.4	  -8.0
PUNTA ARENAS             	 -70.9	 -53.1
BRIDGETOWN BARBADOS      	 -59.6	  13.1
SOUTH GEORGIA            	 -36.8	 -54.2
TRINCOMALT               	  81.2	   8.6
ACID BEACH               	  14.2	  37.1
92 BERTH SCAPA           	  -3.0	  59.0
ELLIS BAY                	 -64.3	  49.8
FARLANE                  	  -4.8	  56.1
ISMAILIA                 	  32.3	  30.6
Z5 BELFAST LOUGH         	  -5.6	  54.7
KHOR JARANA              	  59.7	  22.5
JUBAL STRAITS            	  33.9	  27.7
FIUME                    	  14.4	  45.3
ARANCI BAY               	   9.6	  41.0
LABERVRACH               	  -4.6	  48.6
PRINCESS DOCK            	  -3.0	  53.4
ANTOFAGASTA              	 -70.4	 -23.6
FREETOWN, S. L.          	 -13.2	   8.5
KUCHING                  	 110.4	   1.4
MANSA BAY                	  39.1	  -5.0
ST PAULS BAY             	  14.4	  35.9
AKYAB                    	  92.9	  20.1
SEADLER HARBOUR          	 147.3	  -2.0
FAMAGUSTA                	  34.0	  35.1
LOS PALMOS               	 -16.1	  28.6
ARAUCI BAY               	   9.6	  41.0
BARCELONA                	   2.2	  41.4
BELHAM                   	 -48.5	  -1.5
MALACCA                  	 102.2	   2.2
SINGAPORE NB             	 103.8	   1.4
TOMPKINSVILLE            	 -74.1	  40.6
KOWLOON CAMBER           	 114.2	  22.3
EDENBURGH DOCK           	  -3.2	  56.0
WOOSUNG                  	 121.5	  31.4
ST VINCENT               	 -25.0	  16.8
DUALA                    	   9.7	   4.0
N SHIELDS                	  -1.5	  55.0
HASLAR CREEK             	  -1.1	  50.8
SABIC BAY                	 120.2	  14.7
PALLIKULA BAY            	 167.2	 -15.5
GULF OF MARTABAN         	  97.6	  16.5
AQABA                    	  35.0	  29.5
PORT SHELTER             	 114.3	  22.4
MUDROS                   	  25.3	  39.9
CURACAS                  	 -77.1	   1.8
TIMARU                   	 171.2	 -44.4
MADDALENA                	   9.4	  41.2
NANOOSE                  	-124.2	  49.2
PORT OF SPAIN TRINID     	 -61.5	  10.7
KILLINDINI               	  39.8	  -5.0
BOOM DEFENCE PIR KOW     	 114.2	  22.3
AGACCIO                  	   8.7	  41.9
35TH PIER                	 -74.0	  40.7
SWATAW                   	 116.7	  23.4
PORT SWELTENHAM          	 101.4	   3.0
PROFRIANO                	   8.9	  41.7
PARLATORIO WHARF         	  14.5	  35.9
NO 4 PIER NORFOLK        	 -76.3	  36.9
T O B                    	  -4.8	  56.0
NAKOS                    	  25.5	  37.1
COCANADA                 	  82.2	  16.9
BATAIRA                  	  92.8	  20.5
PALERMO                  	  13.4	  38.1
SERANGOON HARBOUR        	 103.9	   1.4
REPAIR BASE SAN DIEG     	-117.2	  32.7
VEJLE                    	  10.3	  55.3
LOUREUCO MARQUES         	  32.5	 -26.0
DALHOUSIE                	 -66.4	  48.1
MARGIL                   	  47.8	  30.6
AARKUS                   	  10.2	  56.1
PENG CHAN ROADS          	 121.5	  31.7
MORSE D. DOCK NEW BR     	 -74.0	  40.7
LAMACA                   	  33.6	  34.9
SEYDIOFJORDUS            	 -13.8	  65.3
PICTON                   	 174.0	 -41.3
MUSGRAVE CHANNEL         	  -5.9	  54.6
LOANDA                   	  13.2	  -8.8
MA QIL                   	  47.8	  30.6
RESYTH                   	  -3.4	  56.0
HVALFJORDUN              	 -21.7	  64.4
MALTA                    	  14.5	  35.9
PUERTO BELGRANO          	 -62.1	 -38.9
PORT CHALMERS            	 170.6	 -45.8
HALMSTAD                 	  13.0	  56.0
JEDDA                    	  39.2	  21.5
INHAMBANC                	  35.1	 -23.3
WILLOUGHBY DOCK          	 -76.3	  36.9
OH MERCURY BAY           	 175.8	 -36.8
MARSA XLOKK              	  14.5	  35.8
MORSE DOCK               	 -74.0	  40.7
ST TROPEZ                	   6.6	  43.3
LERWICK                  	  -1.1	  60.1
SANTA MARGHERITA         	  14.9	  38.5
JAMES WATT DOCK          	  -4.8	  55.9
HAVANA                   	 -82.4	  23.1
NO 8 DOCK PORTSMOUTH     	  -1.1	  50.8
PORT SWETTENHOUSE        	 101.4	   3.0
SUBIC BAY                	 120.2	  14.7
PORT TOWNSEND            	-122.8	  48.1
DUNEDIN                  	 170.5	 -45.9
FLEETWOOD                	  -3.0	  53.9
CHEMULPHO                	 126.7	  37.5
CHINGWANGTAO             	 119.6	  39.9
PANAMA                   	 -79.5	   9.0
N WALL HONG KONG         	 114.1	  22.3
PORT MELBOURNE           	 144.9	 -37.8
B4 BERTH GREENOCK        	  -4.8	  55.9
NW PORTSMOUTH            	  -1.1	  50.8
M MOORINGS PORTSMOUT     	  -1.1	  50.8
COLOMBO HARBOUR          	  79.9	   6.9
PARLATORIA WHARF         	  14.5	  35.9
PARLATORIO WHARF MAL     	  14.5	  35.9
LOCH CONIE               	  -5.6	  55.3
B 3 BERTH GREENOCK       	  -4.8	  55.9
PORTSMOUTH NO 5 BERT     	  -1.1	  50.8
INHAMBANE                	  35.1	 -23.3
TOR BAY                  	 -52.7	  47.7
NORTH WALL PORTSMOUT     	  -1.1	  50.8
MAJUNGA                  	  46.3	 -15.7
PATRAS                   	  21.7	  38.2
JARROW SLACKS            	  -1.5	  55.0
E 1 BUOY GREENOCK        	  -4.8	  55.9
PERIM                    	  43.4	  12.7
LOCH RANZA               	  -5.3	  55.7
PORT AU PRINCE           	 -72.3	  18.5
WEI HAI WAI              	 120.6	  24.3
KILIDINI                 	  39.8	  -5.0
ARGENTIA                 	 -54.0	  47.3
TULLEAR                  	  43.7	 -23.4
ROSAIRO                  	 -60.7	 -33.0
PAROS                    	  25.1	  37.1
BELIZE                   	 -88.2	  17.5
FARM COVE                	 151.2	 -33.9
DALMUIR DOCK GLASGOW     	  -4.4	  55.9
BAYONNE                  	  -1.5	  43.5
TRINTSIN                 	 117.2	  39.1
BIGERIA                  	  13.5	  38.1
NO 3 BASIN PORTSMOUT     	  -1.1	  50.8
INGENIENO WHITE          	 -62.3	 -38.8
KHOR JARAMA              	  59.7	  22.5
ST THOMAS                	 -59.6	  13.2
PERY MAIN TIC QUAY       	  -1.5	  55.0
CHINWANGTAS              	 119.6	  39.9
PENDING                  	 110.4	   1.6
NUKUALOFA                	-175.2	 -21.1
KHOR KALIGA              	  50.6	  26.2
STAWANGER                	   5.8	  59.0
TYNEMOUTH                	  -1.4	  55.0
LOCH EWE                 	  -5.7	  57.8
PAGO PAGO                	-170.7	 -14.3
ARIEGE BAY               	 -56.0	  51.2
JEDDAH                   	  39.2	  21.5
GANDIA                   	  -0.2	  39.0
ROSYTH IN NO. 1 DOCK     	  -3.4	  56.0
OSLO                     	  10.8	  59.9
SALDANNA BAY             	  18.0	 -33.1
ABA ZENIMA               	  33.1	  29.0
SAMOS BAY                	  20.6	  38.3
B1 BERTH T O B           	  -4.8	  56.0
SEYDISFJORDUR            	 -13.8	  65.3
DOUGLAS IOM              	  -4.5	  54.1
SHARJAH                  	  55.8	  25.0
ARDOSSAN                 	  -4.8	  55.6
T.I.C. DOCK N SHIELD     	  -1.5	  55.0
TOLO HARBOUR             	 114.2	  22.4
CANNES                   	   7.0	  43.5
SEIDISFJORD              	 -13.8	  65.3
PRINCES DOCK GLASGOW     	  -4.3	  55.9
T I C NORTH SHIELDS      	  -1.5	  55.0
AROCHAR                  	 -74.1	  40.6
GRASSY BAY BERMUDA       	 -64.8	  32.3
ABU ZENIMA               	  33.1	  29.0
ROTHSAY                  	  -5.1	  55.8
K G V DOCK GLASGOW       	  -4.4	  55.9
KHIOS                    	  26.0	  38.4
MAR DEL PALTA            	 -57.5	 -38.0
GARDEN ISLAND            	 150.6	 -35.1
KAGOSHIMA                	 130.6	  31.6
N O B  NORFOLK           	 -76.3	  36.9
CARRADALE BAY            	  -5.5	  55.6
SCARBOROUGH              	  -0.5	  53.9
BAHIA DE MALDONADO       	 -54.9	 -34.7
HURDIA                   	  51.1	  10.5
SOUTH BOSTON             	 -71.0	  42.3
MCVAGISSEY               	  -4.8	  50.3
U.S. NAVY YD BROOKLY     	 -74.0	  40.7
HOLLANDIA                	 140.7	  -2.5
OPORTO                   	  -8.6	  41.1
E WALL HONG KONG         	 114.1	  22.3
BETIO TARAWA             	 172.9	   1.4
COCKATOO ISLAND          	 151.2	 -33.8
MILFORD SOUND            	 167.9	 -44.7
ROYAL ROADS              	-123.6	  48.2
PORT HARCOURT            	   7.0	   4.8
LONG HOPE                	  -3.2	  58.8
PRINCESS DOCK BOMBAY     	  72.9	  18.9
LUDEITZ BAY              	  14.5	 -23.0
MARUS                    	 135.3	  34.2
CALDER HARBOUR           	 104.1	   1.4
COMERBROOK               	 -57.9	  49.0
DELOS                    	  25.3	  37.4
KINGSTOWN                	 -61.2	  13.1
IQUIQUE                  	 -70.2	 -20.2
ARCHANGEL                	  40.5	  64.6
PORT AMELIA              	  40.5	 -13.0
PORT SAUNDERS            	 -57.3	  50.6
URMSTON ROADS            	 113.9	  22.3
MONROVIA                 	 -10.8	   6.3
FUNCHAL BAY MADIERA      	 -16.9	  32.6
MENTON                   	   7.5	  43.8
ARUBA                    	 -70.0	  12.5
LOCH CRIBOLL             	  -4.7	  58.5
TE RAWHITI               	 174.2	 -35.2
BANGKOK                  	 100.5	  13.8
BRIDGETOWN  BARBADOS     	 -59.6	  13.1
MANGALORE                	  74.8	  12.9
PORT ORCHARD             	-122.6	  47.5
14TH PIER STATEN ISL     	 -74.2	  40.6
5TH ST PIER HOBOKEN      	 -74.0	  40.7
MERSA HALAIB             	  36.6	  22.2
PASIR PANJANG            	 103.8	   1.3
DOMINICO                 	 -61.4	  15.3
PUERTO CORRAL            	 -73.4	 -39.9
PORT. T                  	  32.6	  29.9
SELLTER                  	  11.1	  59.0
MALMO                    	  13.0	  55.6
PANANG                   	 122.7	  14.3
GREENOCH                 	  -4.8	  55.9
CHESAPEAKE RIVER         	 -76.0	  37.0
CONGO RIVER              	  12.4	  -6.1
91 BERTH, SCAPA          	  -3.0	  59.0
GREAT BRITTEN LAKE       	  32.4	  30.3
CALDETAS                 	   2.5	  41.6
RAPHAEL                  	   4.7	  43.6
KILINDIINI               	  39.8	  -5.0
TAIL OF BANK B5          	  -4.8	  56.0
CHANAI                   	 145.0	  43.1
FREETOWN SIERRA LEON     	 -13.2	   8.5
PORT DARWIN              	 130.8	 -12.4
HORMUZ                   	  56.5	  27.1
ROSYTH DECKYARD          	  -3.4	  56.0
MORSEL BAY               	  22.2	 -34.1
NUHUALOFA                	-175.2	 -21.1
MALTA GH                 	  14.5	  35.9
BANGKOK BAR              	 100.6	  13.4
AMORY                    	 118.1	  24.5
DOUGLAS                  	  -4.5	  54.1
PONTA DELGADA            	 -25.7	  37.7
MORSE `D` DOCK NEW B     	 -74.0	  40.7
GULF OF SALERNO          	  16.4	  39.4
NORFOLK BAY              	 147.8	 -43.0
PORT AUGUSTA             	  15.2	  37.2
H M DOCKYARD HONG KO     	 114.2	  22.3
LOCH LONG                	  -4.9	  56.1
START BAY                	  -3.6	  50.2
ALBANY                   	 117.9	 -35.0
PORT ADELAIDE            	 138.5	 -34.9
HM DOCKYARD HONG KON     	 114.2	  22.3
SO SHIELDS               	  -1.4	  55.0
BARRY ROADS              	  -3.3	  51.4
K G V                    	   0.1	  51.5
PORT OF LOS ANGELES      	-118.3	  33.7
GILKICKER POINT          	  -1.1	  50.8
GISBORNE                 	 178.0	 -38.7
ROYALE ALBERT DOCK       	   0.1	  51.5
MARTINIQUE               	 -61.0	  14.7
COCKATOO IS DOCK         	 151.2	 -33.8
NO 7 TROT FORT BLOCK     	  -1.1	  50.8
BASE SINGAPORE           	 103.8	   1.5
SINGAPORE N.B.           	 103.8	   1.5
SWANSEA                  	  -4.0	  51.6
WALKER NAVAL YARD        	  -1.6	  55.0
SARAGOON HARBOUR         	 103.9	   1.4
NEWQUAY                  	  -5.1	  50.4
LARGS                    	  -4.8	  55.8
DOVER                    	   1.3	  51.1
T I C QUAY NORTH SHI     	  -1.5	  55.0
ST GEORGES HARBOUR G     	 -61.8	  12.1
TAKORASI                 	  -2.0	   6.3
WICHSI BAY               	  19.0	  78.5
BIZERTE                  	   9.9	  37.3
ABERLADY BAY             	  -2.9	  56.0
MUKALLA                  	  49.1	  14.5
KHOR JANAINA             	  53.4	  24.2
LOBITOS                  	-122.4	  37.4
NO 8 BERTH DEVONPORT     	  -4.2	  50.4
MOLACCA                  	 102.2	   2.2
PIRAUES                  	  23.6	  38.0
GASFE                    	 -64.5	  48.8
KEPPEL HARBOUR           	 103.8	   1.3
SERANGOON HBR            	 103.9	   1.4
KHOL KUWAI               	  56.4	  26.4
COQUIMBO                 	 -71.3	 -29.9
PORT OF SPAIN, TRINI     	 -61.5	  10.7
COSMOPOLITAN DOCK        	 114.2	  22.3
GT BITTER LAKE           	  32.4	  30.3
CHIMBOTE                 	 -78.6	  -9.1
APIA                     	-171.7	 -13.8
CINDAD TRUJILLO          	 -69.9	  18.5
DELFT                    	   4.4	  52.0
HVALFJORDOR              	 -21.7	  64.4
KOLA INLET VAENGA BA     	  33.5	  69.2
NEW CASTLE               	  -1.6	  55.0
AWAUA BAY                	 -70.0	  12.5
CALICUT                  	  75.8	  11.2
ELDERSLIE DOCKS          	  -4.5	  55.8
OAMARU                   	 171.0	 -45.1
EL PARELLO               	  -0.3	  39.3
PANAMA CITY              	 -79.5	   9.0
STARLING INLET           	 114.2	  22.5
KISMAYO                  	  42.5	  -0.4
DIBAH                    	  56.3	  25.6
GREENOCK ANCHORAGE       	  -4.8	  56.0
MADDALINA                	   9.4	  41.2
ST. HELENA               	  -5.7	 -15.9
COQUINBO                 	 -71.3	 -29.9
TAKU BAY                 	-135.0	 -23.1
PICTOU                   	 -62.7	  45.7
MERKLANDS WHARF          	  -4.3	  55.9
CHEVBOURGH               	  -1.6	  49.6
INVER GORDON             	  -4.2	  57.7
MATSA ISLAND             	 119.9	  26.1
SEYDIS FJORD             	 -22.9	  66.0
DUBAI                    	  55.3	  25.3
RIO GRANDE DO SUL        	 -51.2	 -30.0
PAHI BAY                 	 174.3	 -35.3
STONEWAY                 	  -6.4	  58.2
SHAWAMIYA                	  55.9	  17.9
RANGOON RIVER            	  96.3	  16.5
CHINWANGTAA              	 119.6	  39.9
W ALVIS BAY              	  14.5	 -22.9
SINGAPORE FLOATING D     	 103.7	   1.3
LABUAN AMARK             	 115.2	   5.3
DUNECLIN                 	 170.5	 -45.9
NOSEI BE                 	  48.2	 -13.3
KEPPER HARBOUR SINGA     	 103.8	   1.3
VALIKA BAY               	  23.5	  38.0
RAS GARIB                	  33.1	  28.4
MORMUGAO                 	  73.8	  15.4
GIB                      	  -5.3	  36.1
R N BASE SINGAPORE       	 103.8	   1.5
MERMEL KEBIS             	  -0.7	  35.7
MAFUNGA                  	  36.6	 -18.3
TALARA                   	 -81.3	  -4.6
DJIBOUTI                 	  43.1	  11.6
PORT IBRAHAM             	  32.6	  29.9
RENOWN ANCHORAGE         	 175.1	 -37.6
SCAPA FLOW PENTLAND      	  -3.1	  58.9
MARGATE                  	   1.4	  51.4
KYAUK PYU                	  98.8	  12.6
35TH ST PIER             	 -74.0	  40.7
ROSTHSAY                 	  -5.1	  55.8
TALCAHVANO               	 -73.1	 -36.7
PRINCE RUPERT B.C.       	-130.3	  54.3
DE BERTH PRINCESS DO     	  -3.0	  53.4
SYRACUSE                 	  15.3	  37.1
SAUGOR ISLAND            	  88.1	  21.7
LABERWRACH               	  -4.6	  48.6
9 6 BERTH, SCAPA         	  -3.0	  59.0
DE BERTH                 	  -3.0	  53.4
LA GOULETTE              	   9.8	  37.2
PORTA PRAYA              	 -23.5	  14.9
DOCKYARD HONG KONG       	 114.2	  22.3
STATTEN ISLAND           	 -74.2	  40.6
DREGER HARBOUR           	 147.9	  -6.7
SANDAHAM                 	 121.0	  14.6
BIRKERHEAD               	  -3.0	  53.4
BANDAR ABBAS, P.G.       	  56.3	  27.2
LONGHOPE                 	  -3.2	  58.8
N ARM HONG KONG          	 114.2	  22.3
CROOKED HARBOUR          	 114.3	  22.6
SHIELDHALL               	  -4.4	  55.9
OTARU                    	 141.0	  43.2
WATSONS BAY              	 151.3	 -33.9
COCOS ISLANDS            	  96.8	 -12.0
GARILOCH                 	  -5.7	  57.7
DARTSMOUTH               	  -3.6	  50.4
BANDRA ABBAS, P.G.       	  56.3	  27.2
SASEBO                   	 129.7	  33.2
OCEAN IS                 	 169.5	  -0.9
JARROW BUOYS             	  -1.5	  55.0
NWW HONG KONG            	 114.1	  22.3
SAN FANCISCO             	-122.4	  37.8
OKHA                     	  69.1	  22.5
DALMUIR WEST             	  -4.4	  55.9
JARROW STAKE             	  -1.5	  55.0
JOSS HOUSE BAY           	 114.3	  22.5
MADDELENA                	   9.4	  41.2
PORT SWEFFINHAM          	 101.4	   3.0
PORT SWETTONHOUSE        	 101.4	   3.0
AKURYRI                  	 -18.1	  65.7
COLUMBO                  	  79.8	   6.9
LOUGH LARNE              	  -5.8	  54.9
PORT TEMPIK              	  32.6	  29.9
S R J PORTSMOUTH         	  -1.1	  50.8
GEELONG                  	 144.3	 -38.2
LEITH                    	  -3.2	  56.0
GUAM PORT APIA           	 144.7	  13.4
NEB TOWER                	  -1.0	  50.7
SALAMIS                  	  23.5	  38.0
KHOLKUWAI                	  56.4	  26.4
SERANGEAU                	 101.9	  -3.4
NO 2 TROT FORT BLOCK     	  -1.1	  50.8
B. ALULA                 	  50.8	  12.0
FISHGUARD                	  -4.9	  52.0
VIZAGAPATAN              	  83.3	  17.7
NO 1 TROT FORT BLOCK     	  -1.1	  50.8
BIERA                    	  34.8	 -19.8
LAUNCESTON               	 147.2	 -41.5
HONG HONG                	 114.2	  22.2
DEVONPORT N YARD         	  -4.2	  50.4
GOVAN & GREENOCK         	  -4.3	  55.9
HSINKONG                 	 121.6	  31.8
CHARLOTTE TOWN           	 -61.4	  15.3
SAN DEIGO USA            	-117.2	  32.7
HUACHO                   	 -77.6	 -11.1
PORT ABERCROMBIE         	 175.3	 -36.1
HALIFER                  	 -63.6	  44.6
TAIL OF THE BANK GRE     	  -4.8	  56.0
MANDAPAM                 	  79.1	   9.3
STOKES BAY               	  -1.2	  50.8
WAI HAI WEI              	 120.6	  24.3
WARRI                    	   6.2	   4.3
DARWIN                   	 130.8	 -12.5
SANTOS,BRAZIL            	 -46.3	 -23.9
V J ANCHGE PENANG        	 100.2	   5.4
WHAUGAREI HEAD           	 174.5	 -35.8
FOOCHOW                  	 119.3	  26.1
POINT FORTIN             	 -61.7	  10.2
HOLYHEAD                 	  -4.6	  53.3
RIO JANEIRO              	 -43.2	 -22.9
VALLETTE                 	 -72.3	  19.6
LYME REGIS               	  -2.9	  50.7
TABLE BAY                	  18.4	 -33.9
CATHERINE BAY            	 175.3	 -36.1
HONOLULU                 	-157.9	  21.3
SANTIAGO DE CUBA         	 -75.8	  20.0
WAIWEIHEI                	 120.6	  24.3
PORTLAND HARBOUR         	  -2.5	  50.6
GRAVING ROCK             	  -5.3	  36.1
GH MAUGAWAI RIVER        	-174.0	 -36.1
KHOR KIWAI               	  56.4	  26.4
TAIHOO                   	 114.0	  22.3
KHOR KUWAIT              	  47.9	  29.4
DAR ES SALAMIS           	  39.3	  -6.8
SANDEKAN                 	 118.1	   5.8
GREAT MERCURY BAY        	 175.8	 -36.6
KHOR KUINAI              	  56.4	  26.4
DARTMOUTH                	  -3.6	  50.4
SMOOGROO BAY             	  -2.1	  58.9
OH RED MERCURY I         	 175.9	 -36.6
WEIHEIWEI                	 120.6	  24.3
ROLLWAY JETTY COCHIN     	  76.2	  10.0
BAY ST GEORGE            	 -58.5	  48.4
KILLINDINNI              	  39.8	  -5.0
BEN ACCORD HARBOR        	 174.8	 -36.4
PUERTO MONTT             	 -72.9	 -41.5
CHARLOTTETOWN            	 -63.1	  46.2
MEDAN                    	  98.7	   3.6
ABERYSTWYTH              	  -4.1	  52.4
NORTH ARM WALL HONG      	 114.2	  22.3
WHAMPON DOCK             	 114.2	  22.3
KUALA JOHNS              	  96.1	   5.3
KUNE                     	 138.5	  35.0
GRENADA                  	 -61.7	  12.1
KHOR KUWA                	  56.4	  26.4
NORTH LANTAU             	 113.9	  22.2
FOOCHON                  	 119.3	  26.1
KHOR JAVANA              	  59.7	  22.5
BAN ACCORD HARBOUR       	 174.8	 -36.4
N O B NORFOLK            	 -76.3	  36.9
GOA                      	  73.9	  15.5
BAYONNE TERMINAL         	  -1.5	  43.5
LUANDA                   	  13.2	  -8.8
GEORGETOWN ARCENCIAN     	 -14.4	  -7.9
VATICA BAY               	  23.0	  36.5
BOURNEMOUTH              	  -1.9	  50.7
NO. 46 DOCK SOUTHAMP     	  -1.4	  50.9
LATZI                    	  32.4	  35.0
BIGHI BAY                	  14.5	  35.9
FUKUOKA                  	 130.4	  33.6
DUNDRUM BAY              	  -5.8	  54.2
AKAROA                   	 173.0	 -43.8
MAHE                     	  55.5	  -4.6
GRAND HARBOUR MALTA      	  14.5	  35.9
TELRAN REACH             	 103.8	   1.5
LIFUKA                   	-174.3	 -19.8
PAYTA                    	 -77.3	   7.9
TOMKINSVILLE BAY         	 -74.1	  40.6
DOCKYARD BASIN HONG      	 114.2	  22.3
SALEMO BAY               	  14.7	  40.5
WHANTON DOCK             	 114.2	  22.3
PYRMOND JETTY            	 151.2	 -33.9
KUALA JAHRE              	 101.2	   5.5
BALLS BANK               	  14.4	  36.0
ELPHINSTONE INLET        	  56.3	  26.2
LOCH FOYLE               	  -7.1	  55.1
SAGAMI BAY               	 139.2	  35.3
VATIKA BAY               	  23.0	  36.5
KAMARAU                  	 123.1	  -5.2
SWATON                   	  -0.3	  52.9
SARDAM BAY               	  15.0	  77.6
BERMUDA DOCKYARD         	 -64.8	  32.3
GEORGETOWN ASCENSION     	 -14.4	  -7.9
TSMALIA                  	  22.9	  38.5
WALLSEND DOCK            	  -1.6	  55.0
A F D ROTHESAY           	  -5.1	  55.8
LIMA CHANNEL             	 114.3	  22.1
DIGBY                    	  -0.4	  53.1
EL PERELLO               	  -0.3	  39.3
TANJONG PRIOR            	 106.9	  -6.1
WILLEMSTAD               	 -57.6	   6.3
HEMPSTEAD HARBOUR        	 -73.6	  40.7
KOLA INLET.              	  33.5	  69.2
PEARL HARBOR             	-158.0	  21.4
LAUTOKA                  	 177.5	 -17.6
SELETAR                  	 103.9	   1.4
SULLAN VOC.              	  -1.3	  60.5
NO 2 GLADSTONE DOCK      	  -3.0	  53.4
TIMARA                   	  39.1	  41.0
BOMBAY ROADS             	  72.9	  18.9
KEPPEL HARBOR            	 103.8	   1.3
FRAMANTLE                	 115.8	 -32.0
NURVEA                   	 178.8	 -16.5
COCHIN NO 9 BERTH        	  76.2	  10.0
ABADAN.                  	  48.8	  30.2
14 PYRMONT               	 151.2	 -33.9
KHOR GHUBB ALI           	  56.4	  26.3
SERANGOON ANCHORAGE      	 103.9	   1.4
FOWLERTON PATCHES        	 103.0	   1.7
PARACELE ISLAND          	 112.2	  16.5
NO 46 DOCK SOUTHAMPT     	  -1.4	  50.9
BRODICK BAY              	  -5.1	  55.6
CRANEY ISLAND            	 -77.1	  38.6
GREAT BITTER LAKE        	  32.4	  30.3
SEYCHELLIS               	  55.7	  -4.6
MARSEILLAS               	   5.4	  43.3
CHING WANG TAO           	 119.6	  39.9
W ALVIS BAY              	  14.5	 -22.9
MEDIL                    	  -3.0	  56.2
M S JETTY PORTSMOUTH     	  -1.1	  50.8
FUNCHAL                  	 -16.9	  32.6
MIN RIVER OUTER BANK     	 119.5	  26.1
KILINDINE                	  39.8	  -5.0
PORT SAID DOCKYARD       	  32.3	  31.3
NWW PORTSMOUTH           	  -1.1	  50.8
ULITHIE                  	 139.7	  10.0
SOUTH WALL ROSYTH        	  -3.4	  56.0
HOY DOCKYARD             	  -3.3	  58.9
BOOM DEFENCE PER KOW     	 114.2	  22.3
DURBAN WHARF             	  31.1	 -29.9
KHASAL BAY               	  56.2	  26.2
BARROW IN FURNESS        	  -3.2	  54.1
AWOCHAR                  	  -4.7	  56.2
MARSAXLOKK BAY           	  14.5	  35.8
LAMLASH HARBOUR          	  -5.2	  55.5
BEYT IS ANCHORAGE        	  69.1	  22.5
TOLO CHANNEL             	 114.2	  22.4
MIN RIVER ENTRANCE       	 119.5	  26.1
SCOTTS GREENOCK          	  -4.8	  55.9
FANNING IS               	-159.3	   3.9
HOLY DOCK                	  -4.9	  56.0
HARRISON COVE            	 167.9	 -44.6
FRENCH CREEK             	  14.5	  35.9
BERWICK                  	  -2.0	  55.8
ADU ATOLL                	  73.2	  -0.6
B D PUR KOWLOON          	 114.2	  22.3
KHA KUWAI                	  56.4	  26.4
PORT BANNATYNE           	  -5.1	  55.9
PORT PHILLIP             	 144.9	 -38.1
SANCHIAKWAN              	 126.5	  33.5
ALEX                     	  -3.0	  53.4
CAMBELTOWN               	  -5.6	  55.4
P DEL ESTE               	 -79.1	   8.4
RED BAY                  	  -6.0	  55.1
SCALPSIE BAY             	  -5.1	  55.8
NICE                     	   7.2	  43.7
BUTARIKARI               	 172.8	   3.1
SKELMORLIE               	  -4.9	  55.9
ELPHINSTON INLET         	  56.3	  26.2
ILLAHEE & BREMERTON      	-122.6	  47.6
KHER KUWAIT              	  47.9	  29.4
PORT BONET               	  -4.0	   5.2
LAZARETT CREEK           	  14.5	  35.9
KIRIBILLI BERTH          	 151.2	 -33.9
NALACCA                  	 102.2	   2.2
SALDANHA                 	  18.0	 -33.1
ABU DHABI                	  54.4	  24.4
PALK STRAITS             	  79.8	  10.0
POLL BAY                 	  -5.3	  58.1
YOKAHAMA                 	 139.6	  35.5
MAIN TIC QUAY            	  -1.5	  55.0
SANDAHAN                 	 118.1	   5.8
REYKJAVIT                	 -21.9	  64.1
PORT THEWFIK             	  32.6	  29.9
SKIATHOS                 	  23.5	  39.2
LARNACA                  	  33.6	  34.9
CHINGWANGTAA             	 119.6	  39.9
FEBRUARY                 	 -75.8	  23.5
P SAID                   	  32.3	  31.3
PORT LOUIS MAURITIUS     	  57.5	 -20.2
MANSARELOKK              	  14.5	  35.8
ABA ZENIMA BAY           	  33.1	  29.0
MANNUS ISLAND            	 147.0	  -2.2
BASSETERRE ST KITTS      	 -62.7	  17.3
PORT BARENICA            	  35.5	  23.9
CANAL TRANSIT            	 -73.7	 -44.8
LAKE TOWN                	  88.4	  22.6
FERNANDO PO              	   8.7	   3.5
NO 14 PIERMONT           	 -73.9	  41.0
DOCK N SHIELDS           	  -1.5	  55.0
CHINWAUGTAO              	 119.6	  39.9
LONG HOPE SCAPA          	  -3.2	  58.8
YARMOUTH                 	  -1.5	  50.7
WHANGARURU               	 175.6	 -36.7
OH RED MERCURY ISLAN     	 175.9	 -36.6
MULLER                   	 -73.7	  18.4
PAHMA                    	   2.6	  39.6
ANDORES AT APPROACH      	 129.7	  41.6
MORTON BAY               	   9.2	   4.0
T O B B1 BERTH           	  -4.8	  56.0
OH WAIKAWAI BAY          	 175.5	 -36.6
SCOTSTOWN                	  -5.6	  56.7
POMPEY                   	  -1.1	  50.8
JAFFNA                   	  80.0	   9.7
MORIB ANCHORAGE          	 101.4	   2.8
KHA NOWARAT              	  38.3	  18.2
AKREYRI                  	 -18.1	  65.7
MORSE DAY DOCK           	 -74.0	  40.7
CALAIS                   	   1.8	  51.0
TACOMA & ILLAHEE         	-122.4	  47.3
LOCH RANIA               	  -5.3	  55.7
JARROW SLADE             	  -1.5	  55.0
MARTA SEIROCCO           	  14.5	  35.8
KHA JARAMA               	  59.7	  22.5
D E BERTH PRINCESS D     	  -3.0	  53.4
ELAYU                    	  48.9	  11.2
YOKCHAMA                 	 139.6	  35.5
36TH ST PIER             	 -73.9	  40.8
SEA AT PANAMA CANAL      	 -79.9	   9.3
5TH STREET PIER HOBO     	 -74.0	  40.7
CATHERINES BAY           	  -2.0	  49.2
YANGTGE DELTA            	 120.5	  31.2
PAROS STRAIT             	  25.1	  37.1
TWOFOLD BAY              	 149.9	 -37.1
HEBBUNN                  	  -1.5	  55.0
GREAT NOME ANCHORAGE     	   0.8	  51.5
SOUTH BASIN BERMUDA      	 -64.8	  32.3
COWICHAN                 	-124.2	  48.9
ZAILA                    	  43.5	  11.4
SAN TROPAZ               	   6.6	  43.3
BARBADOS B W I           	 -59.6	  13.1
RIO DE JANARO            	 -43.2	 -22.9
WOOLWICH                 	   0.2	  51.5
GOWOCK                   	 110.3	  -7.1
TOBAGA BAY               	 178.3	 -38.4
VIZAGAPOTAM              	  83.3	  17.7
LOCK RYAN & BELFAST      	  -5.0	  54.9
ROSYTH IN THE BASIN      	  -3.4	  56.0
DRAGON                   	  57.4	 -20.2
TIENTSUI                 	 117.2	  39.1
AS SUWAIK                	  57.4	  23.8
HSUPUKOU                 	 111.3	  31.1
SINGAPORE NAVAL YARD     	 103.8	   1.5
BERTH C3 TRINCOMALEE     	  81.2	   8.6
SUR                      	  59.5	  22.6
WHAUGABOUA BAY           	 175.6	 -36.7
RUS AL HADD              	  59.8	  22.5
AJMAN                    	  55.4	  25.4
CARRIACOA                	 -61.5	  12.5
KHABAB BAY               	  56.2	  26.2
DAHAB                    	  34.5	  28.5
ZABAIR ISLANDS           	  42.2	  15.1
CHERBOURG                	  -1.6	  49.6
FORT DE FRANCE           	 -61.1	  14.6
TAIRIO DOCK              	 114.2	  22.3
SIMON`S TOWN             	  18.4	 -34.2
AKABA                    	  35.0	  29.5
S EDINBURGH CHANNEL      	   1.3	  51.5
ALAMEDA                  	-122.2	  37.8
CHATHAM BAY              	 -87.0	   5.5
ENGLISH BANK             	 -83.7	  12.3
GRIMSBY                  	  -0.1	  53.5
DUNK ISLAND              	 146.2	 -17.9
MANUS IS                 	 147.0	  -2.2
SELETAR ROAD             	 103.9	   1.4
MANUS ISLANDS            	 147.0	  -2.2
COLVILLE BAY             	 175.4	 -36.6
PORT. SEYCHELLES         	  55.5	  -4.6
LA SALINAS               	 -77.6	 -11.3
RYDE                     	  -1.2	  50.7
PORT SHELLER             	 114.3	  22.4
LOCH ALSTE               	  -5.7	  57.2
KOLA INLET & SEIDISF     	  33.5	  69.2
PEARL  HARBOUR           	-158.0	  21.4
VENGA BAY                	  33.4	  69.1
KHOR KUWAI & BANDAR      	  56.4	  26.4
WAIKAWAU BAY             	 175.5	 -36.6
MKOANI                   	  39.6	  -5.4
CRANEY IS                	 -77.1	  38.6
HERVEY BAY               	 153.0	 -25.0
RIO DE JAMAIRO           	 -43.2	 -22.9
CAIRNS                   	 145.8	 -16.9
URMSTON ROAD OF HONG     	 113.9	  22.3
MATRAS                   	  80.2	  13.0
MONTSERRAT               	 -62.2	  16.7
MURRAYS ANCHORAGE        	 -64.7	  32.4
TULEAR                   	  43.6	 -23.4
LARGS BAY                	 138.5	 -34.8
SCRANGOON HARBOUR        	 103.9	   1.4
SALEMO                   	  14.7	  40.5
SEYDISLFJORD             	 -22.9	  66.0
FT GILKICKER             	  -1.1	  50.8
NOSSI BE                 	  48.2	 -13.3
MEYOR ISLAND             	 177.8	 -29.2
VANEGA BAY               	  33.4	  69.1
SARDIS FJORD             	 -22.9	  66.0
AMUREYRIE                	 -18.1	  65.7
TRANSIT PANAMA CANAL     	 -79.9	   9.3
SITRAH ANCHORAGE         	  50.6	  26.1
HORDIA                   	  51.1	  10.6
TEPAKI POINT             	 175.8	 -36.7
MAR DEL PLATA            	 -57.5	 -38.0
PLYMOUTH SONNA           	  -4.2	  50.3
5N KOWLOON               	 114.2	  22.3
BREMENTON                	 -75.5	  38.4
GRAND HARLEUS MALTA      	  14.5	  35.9
PLYMOUTH BAY             	 -70.6	  42.0
B1 BIRTH T O B           	  -4.8	  56.0
HERDMAN CHANNEL          	  -5.9	  54.6
YATIKA BAY               	  23.0	  36.5
WEWAK                    	 143.6	  -3.5
GWADAR BAY               	  61.6	  25.1
SEATTLE & PORT TOWNS     	-122.3	  47.6
SWASOW                   	 116.7	  23.4
CALLIOPE WHARF           	 174.8	 -36.8
PORT KALLONI             	  26.2	  39.2
HAUSAKI GULF             	 175.0	 -36.4
MALTA MASAXLOBB          	  14.5	  35.8
THURSDAY ISLAND          	 142.2	 -10.6
BAY OF ISLANDS           	 174.2	 -35.2
PORT. `T                 	  32.6	  29.9
FALK BAY                 	  79.2	   9.5
TRINCONALEE              	  81.2	   8.6
COX`S BAZAAR             	  92.0	  21.6
CHANGYINSHA              	 120.8	  31.9
TOMPKINSVILLE BAY        	 -74.1	  40.6
BERENICE                 	  20.1	  32.1
LAMBASH                  	 120.0	  15.8
MORSE  DOCK              	 -74.0	  40.7
CASTELLAMARE             	-118.6	  34.0
MONTEGO BAY JAMAICA      	 -77.9	  18.5
LOCH GOIL HEAD           	  -4.9	  56.1
OSLO QUAY                	  10.8	  59.9
UMM AL QAIWAIN           	  56.5	  26.2
TAIKO WAN                	 114.1	  22.3
SINGAPORE KEPPEL HAR     	 103.8	   1.3
MISIRA                   	 -16.0	  13.6
WHAUGAREI HEADS          	 174.5	 -35.8
LORENCO MARQUES          	  32.5	 -26.0
GILBRATAR                	  -5.3	  36.1
TOWNSVILLE               	 146.8	 -19.2
KIIRUN                   	 126.2	  34.5
VALETTA MALTA            	  14.5	  35.9
RIO DE JANIERO           	 -43.2	 -22.9
FIFTH AND GREENOCK       	  -4.8	  55.9
LOLEIYA                  	  42.7	  15.7
ISMALIA                  	  32.3	  30.6
SING. NAVAL BASE         	 103.8	   1.5
ST JOHN`S HARBOR         	 -52.6	  47.6
KOLA INLET VALNEA BA     	  33.5	  69.2
HERMANUS BAY             	  19.2	 -34.4
PORT MAURITIUS           	  57.5	 -20.2
NA WALL HONG KONG        	 114.2	  22.3
WHAUGAPOUA               	 175.6	 -36.7
RAJANG                   	 111.2	   2.1
SCAPA FLOW LA            	  -3.1	  58.9
SANTOS, BRAZIL           	 -46.3	 -23.9
PENZANCE                 	  -5.5	  50.1
G BERTH SAN DIEGO        	-117.2	  32.7
SWAN HUNTERS WALLSEN     	  -1.6	  55.0
PORT. T`                 	  32.6	  29.9
NORFOLK VA               	 -76.3	  36.9
MURRAY`S ANCHORAGE       	 -64.7	  32.4
NORTH SHIELDS AND HE     	  -1.5	  55.0
LUDENTZ BAY              	  14.5	 -23.0
SAVU SAVU                	 178.5	 -16.6
JEZIRAT HINDARALI        	  53.6	  26.7
ROSEAU DOMINICA          	 -61.4	  15.3
ANTIQUA                  	 -61.8	  17.1
TRINCONALI               	  81.2	   8.6
STOKER BAY               	  -1.2	  50.8
HURUKI BAY               	 175.0	 -36.8
SOUTHEND                 	   0.7	  51.5
N BASE JAHORE            	 103.8	   1.5
TOLO HARBOR              	 114.2	  22.4
PORT T`                  	  32.6	  29.9
T I C N SHIELDS          	  -1.5	  55.0
MARSA                    	  14.5	  35.8
KYAUK PYCU HARBOUR       	  93.5	  19.4
CEARA                    	 -44.8	  -1.8
HAIPHONG                 	 106.7	  20.9
GILLKICKER POINT         	  -1.1	  50.8
SUBIE BAY                	 120.2	  14.7
SHINAS                   	  56.5	  24.7
MAN OF WAR               	  -2.2	  50.6
CHALMETTE                	 -90.0	  29.9
MANILA BAY               	 120.8	  14.5
MUSCAL                   	  58.6	  23.6
ST IVIE                  	  -5.5	  50.2
GIBRALTOR                	  -5.3	  36.1
BANNATYNE                	 -59.5	  13.1
BITTER LAKES             	  32.4	  30.3
SHOR KUWAI               	  56.4	  26.4
NO 401 BERTH GUAM        	 144.7	  13.4
NOUMEA  SEA              	 166.4	 -22.3
VAVAR                    	 160.8	  -9.9
TIEUTSUI                 	 117.2	  39.1
SAN FRANCISCO BAY        	-122.4	  37.8
COWES AND RYDE           	  -1.3	  50.8
GUIDE PIER COLOMBO       	  79.9	   6.9
KAMERAN                  	  42.6	  15.3
NAVAL DOCKYARD BERMU     	 -64.8	  32.3
ZUBAIR                   	  42.2	  15.1
CHARLESTOWN SC           	 -79.9	  32.8
TOBAGA                   	 -60.7	  11.2
PENANY                   	 100.2	   5.4
NORFOLK IS               	 167.9	 -29.0
MITHEL                   	  43.9	  13.7
DELAWARE VALLEY          	 -75.1	  40.9
ONEATA                   	 178.5	 -18.9
WRANGELL                 	-132.4	  56.5
BALIKPAPAN               	 116.8	  -1.3
BHARJAH                  	  55.8	  25.0
KHOR ASH SHAMM           	  56.3	  26.2
HONG KONG SEA            	 114.1	  22.3
PORTO PRAYA              	 -23.5	  14.9
AREHAUGEL                	  40.5	  64.6
MOOREA                   	-149.8	 -17.5
NOUMEA FISHERMANS BA     	 166.4	 -22.3
LIFKUA                   	   9.1	  64.1
KHOR ASH SHANNA          	  56.3	  26.2
AKUSEYOI                 	 -18.1	  65.7
PERY MAIN TIC QUEY       	  -1.5	  55.0
ABADAN AND ASHAT         	  48.8	  30.2
JUNK BAY HONG KONG       	 114.2	  22.3
GRANGER                  	  -2.9	  54.2
NEW YORK PIER 88         	 -74.0	  40.8
CHARLOTTE AMALIE         	 -64.9	  18.3
PORT VICTORIA, MAHI      	  55.5	  -4.6
SEGAMI WAN               	 139.4	  35.3
LOURENCE MARQUES         	  32.5	 -26.0
LEYTA                    	 124.5	  11.4
HAIPHOUL                 	 120.2	  23.2
NOUVEA                   	 166.4	 -22.3
HONG KONG HARBOUR        	 114.2	  22.3
AZEAU                    	  -0.3	  35.9
THORSHAUN                	  -6.8	  62.0
TREINSTIEN               	 117.2	  39.1
PUNTA ARINAS             	 -70.9	 -53.1
PORT LEWIS               	  57.5	 -20.2
CANDIA                   	  24.8	  35.2
LOWETOFT                 	   1.8	  52.5
TIC WARF TYNE            	  -1.5	  55.0
MAURITIS                 	  57.5	 -20.2
GREENOCK & GEARSON       	  -4.8	  55.9
SCOTTS BASIN GREENOC     	  -4.8	  55.9
KHOR ABBAS               	  56.3	  27.2
METHILL                  	  -3.0	  56.2
T C Q NORTH SHIELDS      	  -1.5	  55.0
HONG KONG E 2 BERTH      	 114.2	  22.3
DEVONPORT & PLYMOUTH     	  -4.2	  50.4
SEYDISFJONDUR            	 -13.8	  65.3
BOLOVIA                  	  -5.8	  36.1
SINGAPORE N B            	 103.8	   1.5
BEYROUTH                 	  35.5	  33.9
KLASAB BAY PG            	  56.2	  26.2
GREENLOCK                	  -4.8	  55.9
VILA                     	 168.3	 -17.7
KLASAB BAY               	  56.2	  26.2
SOUTH NORFOLK            	 -73.2	  41.9
3D DOLPHIN               	  -1.1	  50.8
KHAR KUWAI               	  56.4	  26.4
NORTH WALL HONG KONG     	 114.2	  22.3
NTH SHIELDS              	  -1.5	  55.0
NA HONG KONG             	 114.2	  22.3
MARSA HOKK               	  14.5	  35.8
ALEXANDRIA DOCK          	  29.9	  31.2
ROYALE ALBERTS DRY D     	   0.1	  51.5
TEINGTAO                 	 120.3	  36.1
TARHOO DRY DOCK          	 114.2	  22.3
GARELOCHEAD              	  -4.8	  56.1
MOSYTH                   	  -3.4	  56.0
NORTH ARM HONG KONG      	 114.2	  22.3
HOLY INLET HOLY LOCH     	  -4.9	  56.0
TAIHOO DOCK              	 114.2	  22.3
BAUDAR ABBAI             	  56.3	  27.2
GUANTANAMA               	 -75.2	  20.1
GT BITTER LAKES          	  32.4	  30.3
NAVAL BASE S`PORE        	 103.8	   1.5
MACHAS                   	  80.2	  13.0
HARWICK                  	   1.3	  52.0
NA AND NW HONG KONG      	 114.2	  22.3
TYNE RIVER               	  -1.6	  55.0
NURVRA                   	 178.8	 -16.5
COCKATOO DOCKYARD        	 151.2	 -33.8
BROOKLYN NAVY YARD N     	 -74.0	  40.7
WEST WALL KOWLOON        	 114.2	  22.3
BANDAR MASKUR            	  49.2	  30.5
FORTH ESTUANG            	  -3.0	  56.2
MARLBOROUGH SOUNDS       	 174.2	 -41.0
BALIKPAPEN               	 116.8	  -1.3
SEYDISJORDEN             	 -13.8	  65.3
MIN RIVER                	 119.5	  26.1
ADDU ATTOL               	  73.2	  -0.6
TAIL OF THE BANK CLY     	  -4.8	  56.0
THOMPSONS DRY DOCK       	  -5.9	  54.6
SAN DIEGO USA            	-117.2	  32.7
P. SUDAN                 	  37.2	  19.6
METHIE                   	  97.5	  17.3
VIZAGAPATRON             	  83.3	  17.7
CLAUDE                   	 -73.4	  18.3
MIN RIVER OUTER BAR      	 119.5	  26.1
T I C  BUOY NO SHIEL     	  -1.5	  55.0
THE HOLY LOCH            	  -4.9	  56.0
NURVERA                  	 178.8	 -16.5
LOCH LATHAICH            	  -6.2	  56.3
LAMLASH GREENOCK         	  -5.2	  55.5
HONG KONG HARBOR         	 114.2	  22.3
UTAH ASSAULT AREA        	  -1.2	  49.4
B SHED PRINCESS DOCK     	  -3.0	  53.4
JAMES WALT DOCK          	  -4.8	  55.9
XAVALLA                  	  24.4	  40.9
PORT SWITEHAM            	 101.4	   3.0
NO 13 BUOY COLOMBO       	  79.9	   6.9
LOCH EVE                 	  -5.7	  57.8
BALTIMORE USA            	 -76.6	  39.3
CAMPBELTON               	 -78.3	  18.4
LOCK RYAN                	  -5.0	  54.9
FALKLAND ISLAND          	 -57.9	 -51.7
GUANTANAMO               	 -75.2	  20.1
BAKHAR                   	  56.2	  26.1
TONGKU                   	 113.9	  22.4
GREENOCK & BELFAST       	  -4.8	  55.9
COCHIN BERTH NO 9        	  76.2	  10.0
ROTHSAY BAY              	  -5.1	  55.8
KOTOR                    	  18.8	  42.4
EDENBURGH                	  -3.2	  56.0
BELFAST LOGH             	  -5.6	  54.7
P SUDAN                  	  37.2	  19.6
KOR GHUBB ALI            	  56.4	  26.3
LOCHLONG                 	  -4.9	  56.1
BAUDAR ABBAS PERSIAN     	  56.3	  27.2
ALBERTA                  	  13.3	  55.6
WHAMPOO                  	 114.2	  22.3
GLASGOW & GREENOCK       	  -4.3	  55.9
STOKES BAY SOLENT        	  -1.2	  50.8
MAGIL                    	  47.8	  30.6
TAMATIVE                 	  49.4	 -18.2
NEPTUNE YARD             	  -1.6	  55.0
KHIOS ISLAND             	  26.0	  38.4
MANDAPAN                 	  80.2	   9.8
NO 2 ROSYTH              	  -3.4	  56.0
POR D JANEIRO            	 -43.2	 -22.9
RIVER PLATE              	 -57.0	 -35.0
AKYAB                    	  92.9	  20.1
SERAGOON                 	 103.9	   1.4
LYNESS                   	  -3.2	  58.8
LOCH GOIL                	  -4.9	  56.1
TAI PO                   	 114.0	  22.3
POUTA DELGADA            	 -25.7	  37.7
LAFSAMI ISLAND           	 113.8	  22.1
LERSICK                  	  -1.1	  60.1
PORT BALLANTYNE          	  -5.1	  55.9
WEST WALL BASIN BOMB     	  72.9	  18.9
SHEERNESS & CHATHAM      	   0.8	  51.4
PANAMA CANAL             	 -79.9	   9.3
ROTTERDAM                	   4.5	  51.9
ARROCHAN                 	  -4.7	  56.2
LOCH LACHAICH            	  -6.2	  56.3
T.I.C. DOCK              	  -1.5	  55.0
SALEN BAY                	 -10.0	  54.2
RINNIGILL PIER           	  -3.2	  58.8
GRANTON ROADS            	  -3.2	  56.0
PRINCES D                	  -4.3	  55.9
GOVAN DOCK               	  -4.3	  55.9
TARAWA                   	 173.0	   1.4
NO 2 BASIN PORTSMOUT     	  -1.1	  50.8
T.I.C. Q.                	  -1.5	  55.0
CAMPBELTOWN AREA         	  -5.6	  55.4
POINT CRUZ               	 159.9	  -9.4
TIVAT                    	  18.7	  42.4
PORT GLASGOW             	  -4.7	  55.9
BURNIE                   	 145.9	 -41.1
PORT KEMBLA              	 150.8	 -34.4
MERSEY BAY               	  -3.2	  53.5
CATACOL BAY              	  -5.3	  55.7
FLINDERS NAVAL DEPOT     	 145.2	 -38.4
DOLPHIN                  	  -1.1	  50.8
CAMPBELTON AREA          	  -5.6	  55.4
BERKLEY                  	 -76.3	  36.8
STROUL BAY               	  -4.8	  56.0
AIROCHAR                 	  -4.7	  56.2
TAILOM BAY               	 114.4	  22.4
TAIKOO                   	 114.2	  22.3
DOUBLE HAVEN             	 114.3	  22.5
DERWICK                  	  -2.7	  59.0
GREAT LADRONE            	 113.7	  21.9
LONDON DOCKS             	   0.1	  51.5
THURSO BAY               	  -3.5	  58.6
TAIPO                    	 114.0	  22.3
TAIO                     	 113.9	  22.2
PORT GOVAN               	  -4.3	  55.9
HAMILTON BERMUDA         	 -64.8	  32.3
HASLAR CREEK PORTSMO     	  -1.1	  50.8
RISAHALLY                	  -7.3	  55.0
T.C.  QUAY               	  -1.5	  55.0
BERKLEY YARD             	 -76.3	  36.8
VERNON PIER              	 152.8	 -25.2
SORRABAYA                	 112.8	  -7.2
TAIL OF BANK CLYDE       	  -4.8	  56.0
PORT SUNLIGHT            	  -3.0	  53.3
ROTHESAY CLYDE           	  -5.1	  55.8
JOANA BAY                	 104.2	   2.8
FLOATING DOCK PORTSM     	  -1.1	  50.8
SKIPNESS BAY             	  -5.3	  55.8
DEVONPORT DOCKYARD       	  -4.2	  50.4
THE PIRAEUS              	  23.6	  38.0
SHOTLEY                  	   1.2	  52.0
HONG KONG DOCKYARD       	 114.2	  22.3
TOILOM BAY               	 125.5	   7.0
LOCH GOLL                	  -4.9	  56.1
SINGAPORE NAVAL          	 103.8	   1.5
WALRIS BAY               	  14.5	 -22.9
RAF BASE SELETAR         	 103.9	   1.4
PORT LINCOLN             	 135.9	 -34.7
GREAT HARBOUR GREENO     	  -4.7	  56.0
TOURABAYA                	 112.8	  -7.2
IEMAILIA                 	  32.3	  30.6
IN HARBOUR EAST LOND     	  27.9	 -33.0
TAI O                    	 113.9	  22.2
BUTE SOUND               	  -5.2	  55.7
AROCHIAR                 	  -4.7	  56.2
TAIWAN BAY               	 114.2	  22.3
HONG  KONG               	 114.2	  22.3
INCHMARNOCK              	  -5.2	  55.8
LUNE                     	  -2.9	  54.0
LONG HARBOR              	 114.3	  22.4
SOUTHPOINTE              	 -80.1	  33.0
LONDONDERRY AND MOVI     	  -7.3	  55.0
HMS DOLPHIN              	  -1.1	  50.8
LOCH GAILHEAD            	  -4.9	  56.1
WOLFE                    	 -71.5	  45.8
OCEAN ISLAND             	 169.5	  -0.9
RIVER YARROW             	 152.1	 -29.7
CHUNG CHAU               	 114.0	  22.2
CATTEDOWN WHARF          	  -4.1	  50.4
LANTAO                   	 113.9	  22.2
PAK LEAK                 	 113.8	  22.0
PORTSMOUTH D 4           	  -1.1	  50.8
ARRICHAR                 	  -4.7	  56.2
MALTAR                   	  14.4	  35.9
JERVIS                   	 -90.7	  -0.4
PENG CHAN HOI            	 114.2	  22.5
ST DUNDEE                	  -3.0	  56.5
LAMBASA                  	 179.4	 -16.4
CATTEDOWN                	  -4.1	  50.4
HIGH SHIELDS             	  -1.4	  55.0
GRANDON ROADS            	 -71.9	  19.4
FORT BLOCHOUSE           	  -1.1	  50.8
TYNE DOCK                	  -1.4	  55.0
SKIPNESS                 	  -5.3	  55.8
ADAMANT                  	  44.2	  13.8
TOBERMARY                	  -6.1	  56.6
NALLACCA                 	 102.2	   2.2
PORT SHELTON             	-123.1	  47.2
HOLYLOCH                 	  -4.9	  56.0
MASLAR CREEK PORTSMO     	  -1.1	  50.8
DELAWARE RIVER           	 -75.5	  39.4
DEVONPORT NORTH YARD     	  -4.2	  50.4
CALLEDAN                 	  -0.1	  51.5
ABERDEEN HARBOUR         	 114.2	  22.2
KAMBASA                  	  23.9	  38.0
BARROW-IN-FURNESS        	  -3.2	  54.1
YARMONTH ROADS           	   1.8	  52.6
ROCKY ISLE               	 119.3	  10.8
CALLEDAN WHARF           	  -0.1	  51.5
TAIKOO DOCKYARD          	 114.2	  22.3
NO 7 TROT PORTSMOUTH     	  -1.1	  50.8
SINGAPORE RAILS          	 103.8	   1.3
FORTH                    	  -3.0	  56.2  # After this point, new for oldweather
SINCLAIR BAY             	  -3.1	  58.5
WALKER-ON-TYNE           	  -1.4	  55.0
PORT WILLIAM             	 -57.8	 -51.7
MURMANSK                 	  33.1	  69.0
ARKHANGEL                	  40.5	  64.6
ARKANGEL                 	  40.5	  64.6
ARABAT BAY               	  35.6	  45.4
CONSTANTINOPLE           	  29.0	  41.0
SEVASTAPOL               	  33.5	  44.6
SEVASTOPOL               	  33.5	  44.6
OCHAKOV                  	  31.5	  46.6
ODESSA                   	  30.7	  46.5
YALTA                    	  34.2	  44.5
ABROLHOS                 	 -38.7	 -18.0  # Brazil, not western Australia
ABROTHOS                 	 -38.7	 -18.0
CROMARTY                 	  -4.0	  57.7
TENEDOS                  	  26.0	  39.8
DEVON PORT               	  -4.2	  50.4
Shanghai                 	 121.5	  31.2  # Yangtzee
Shanghai                 	 121.5	  31.2
Kiang-Nan Dock           	 121.5	  31.2
Jiangnan                 	 121.5	  31.2
Jiang-Nan                	 121.5	  31.2
Chiang-Nan               	 121.5	  31.2
Kiang-Nan                	 121.5	  31.2
Woosung                  	 121.5	  31.4
Woo-sung                 	 121.5	  31.4
Wu-sung                  	 121.5	  31.4
Wusong                   	 121.5	  31.4
Wusungchen               	 121.5	  31.4
Baoshan                  	 121.5	  31.4
Sloping Clump            	 121.4	  31.5
Near Yuepuzhen           	 121.4	  31.5
Dove's Nest              	 121.3	  31.6
Off Chongming            	 121.3	  31.6
Acton Shoals             	 121.2	  31.7
Off Lvhuazhen            	 121.2	  31.7
Centaur Bank             	 121.2	  31.7
Off Lvhuazhen            	 121.2	  31.7
Knuckle                  	 121.1	  31.8
Off Sanhezhen            	 121.1	  31.8
Plover Point             	 120.8	  31.9
Longzhaoyuan             	 120.8	  31.9
Kuishan Point            	 120.9	  31.9
Kushan Point             	 120.9	  31.9
Junshan Scenic Area      	 120.9	  31.9
Tienshien                	 120.8	  32.0
Tungchow                 	 120.8	  32.0
Nantong                  	 120.8	  32.0
Vine Point               	 120.8	  32.0
Opposite Nantong         	 120.8	  32.0
Big Tree                 	 120.7	  32.0
Off Changqingshaxiang Island	 120.7	  32.0
Pitman King Island       	 120.6	  32.0
Changqingshaxiang Island 	 120.6	  32.0
Cooper Bank              	 120.5	  32.0
Cooper Island            	 120.5	  32.0
Off Changqingshaxiang Island	 120.5	  32.0
Rose Island              	 120.4	  32.0
Shuangshan Island        	 120.4	  32.0
Kang Yin forts           	 120.3	  31.9
Kiangyin                 	 120.3	  31.9
Espiegle Rocks           	 120.3	  31.9
Jiangyin                 	 120.3	  31.9
Bate Point               	 120.1	  31.9
Ligangzhen               	 120.1	  31.9
Taishing Station         	 119.9	  32.1
Port of Taixing          	 119.9	  32.1
Taishing                 	 119.9	  32.1
Taixing                  	 119.9	  32.1
Sinnimu Creek            	 119.8	  32.2
Yangzhong cut-off        	 119.8	  32.2
Beaver Island            	 119.7	  32.3
Off Yangzhong            	 119.7	  32.3
Chang Sang Chou          	 119.7	  32.2
Dagangzhen               	 119.7	  32.2
Tasha Island             	 119.6	  32.2
Jiangxinzhen Island      	 119.6	  32.2
Chinkiang                	 119.5	  32.3
Chin-kiang               	 119.5	  32.3
Chinkin                  	 119.5	  32.3
Hsiangshan               	 119.5	  32.3
Zhenjiang                	 119.5	  32.3
Deer Island              	 119.3	  32.2
Pi-Sin-Chau              	 119.3	  32.2
Shiyezhen Island         	 119.3	  32.2
Bethune Point            	 119.2	  32.2
West end of Shiyezhen island	 119.2	  32.2
Ta-Ho-Kau                	 119.1	  32.4
Qingshanzhen             	 119.1	  32.4
Morris Point             	 119.0	  32.2
Morrison Point           	 119.0	  32.2
Lone Tree Hill           	 119.0	  32.2
Qizia Zhen               	 119.0	  32.2
Mud Fort                 	 118.9	  32.2
Qizia                    	 118.9	  32.2
Nanking                  	 118.7	  32.1
Nanjing                  	 118.7	  32.1
Pukow                    	 118.7	  32.0
Pukou                    	 118.7	  32.0
Duck Island              	 118.6	  31.9
Zimuzhou                 	 118.6	  31.9
Pheasant Island          	 118.5	  31.8
Zaishengzhou             	 118.5	  31.8
May Queen Island         	 118.5	  31.7
Xiaohuangzhou            	 118.5	  31.7
Rosina Rock              	 118.5	  31.7
Near Huashan             	 118.5	  31.7
Heasanchan Bluff         	 118.4	  31.7
Heasanchan Point         	 118.4	  31.7
Heasanshan Bluff         	 118.4	  31.7
Jiuhuashan               	 118.4	  31.7
Tai Ping Fu              	 118.5	  31.6
Dangtu                   	 118.5	  31.6
East and West Pillar     	 118.4	  31.5
Rocky Point              	 118.4	  31.5
Erjia                    	 118.4	  31.5
Wade Island              	 118.3	  31.5
Fuzhuang                 	 118.3	  31.5
Haines Point             	 118.3	  31.4
Wangxiang                	 118.3	  31.4
Wu-hu                    	 118.3	  31.3
Wuhu                     	 118.3	  31.3
Shansi Beacon            	 118.2	  31.3
Off Xiaozhouxiang        	 118.2	  31.3
Barker Island            	 118.1	  31.2
Off Xingangzhen          	 118.1	  31.2
Horse Shoe Bend          	 118.0	  31.3
Off Hebazhen             	 118.0	  31.3
Panski Pagoda            	 118.0	  31.1
Digangzhen               	 118.0	  31.1
Osborne Island           	 117.9	  31.1
Off Liuduzhen            	 117.9	  31.1
Two Fathom Creek         	 117.8	  31.1
Near Tongling            	 117.8	  31.1
White Beacon             	 117.8	  31.1
Walled City              	 117.8	  31.1
Walled Village           	 117.8	  31.1
Tuqiaozhen               	 117.8	  31.1
Wu Pa Kau                	 117.8	  30.9
Tongling                 	 117.8	  30.9
Buckminster Island       	 117.7	  31.0
Jeffrey Island           	 117.7	  31.0
Laozhouxiang             	 117.7	  31.0
Perkins Point            	 117.7	  30.9
South tip of Laozhouxiang	 117.7	  30.9
Saint Thomson Island     	 117.7	  30.8
Off Datongzhen           	 117.7	  30.8
Tatung                   	 117.7	  30.8
Datongzhen               	 117.7	  30.8
Muken                    	 117.7	  30.8
Meilongzhen              	 117.7	  30.8
Chichau                  	 117.5	  30.7
Chizhou                  	 117.5	  30.7
Fitzroy Island           	 117.5	  30.7
Off Chizhou              	 117.5	  30.7
Hen Point                	 117.2	  30.6
Kiang Loong Wreck        	 117.2	  30.6
Mashi                    	 117.2	  30.6
Chuang King Kau          	 117.2	  30.5
Xinzhouxiang Island      	 117.2	  30.5
Nganking                 	 117.1	  30.5
Anking                   	 117.1	  30.5
Guankin                  	 117.1	  30.5
Anqing                   	 117.1	  30.5
Jocelyn Island           	 116.9	  30.4
Jiangxinzhou Island      	 116.9	  30.4
Christmas Island         	 116.9	  30.3
Off Hongjiafan           	 116.9	  30.3
Tungliu                  	 116.9	  30.2
Tung-liu                 	 116.9	  30.2
Dongliuzhen              	 116.9	  30.2
False Island             	 116.8	  30.2
Off Fengshoucun          	 116.8	  30.2
Sankau                   	 116.8	  30.1
Sankou Yao               	 116.8	  30.1
Hwangang                 	 116.8	  30.1
Huayangzhen              	 116.8	  30.1
Hwangshiki Bluff         	 116.8	  30.1
Opposite Huayangzhen     	 116.8	  30.1
Dove Point               	 116.5	  29.9
Pengze                   	 116.5	  29.9
Snipe Island             	 116.5	  29.9
Yezihao                  	 116.5	  29.9
Hukau                    	 116.2	  29.8
Hukou                    	 116.2	  29.8
Point Otter              	 116.2	  29.8
NE Crossing              	 116.2	  29.8
Off Hukou                	 116.2	  29.8
Little Orphan            	 116.4	  29.9
Jiangzhoucun             	 116.4	  29.9
Lay Island               	 116.2	  29.8
Jiangzhouzhen            	 116.2	  29.8
Kiukiang                 	 116.0	  29.7
Kiu-kiang                	 116.0	  29.7
Jiujiang                 	 116.0	  29.7
Nankan                   	 116.0	  29.4
Nan-Kang                 	 116.0	  29.4
Xingzi                   	 116.0	  29.4
Wooching                 	 116.0	  29.2
Wuchengzhen              	 116.0	  29.2
Nanchang                 	 115.9	  28.7
Nanchang                 	 115.9	  28.7
Hunter Island            	 115.7	  29.8
Off Longpingzhen         	 115.7	  29.8
Wusueh                   	 115.6	  29.8
Wuxue                    	 115.6	  29.8
Split Hill               	 115.5	  29.8
Opposite Wuxue           	 115.5	  29.8
Low Point                	 115.5	  29.9
near Fuchizhen           	 115.5	  29.9
Havoc Rocks              	 115.5	  29.9
Fuchizhen                	 115.5	  29.9
Hoves Creek              	 115.3	  30.1
Qishui river            	 115.3	  30.1
Shazikou                	 115.3	  30.1
Cock's Head              	 115.2	  30.2
Ke-Tau                   	 115.2	  30.2
Xisai Mountain           	 115.2	  30.2
Shi Hui Yao              	 115.1	  30.2
Shi-hui-yao              	 115.1	  30.2
Sz-hui-you               	 115.1	  30.2
Lee Rocks                	 115.1	  30.2
Xisaishan                	 115.1	  30.2
Wongshik-Kong            	 115.1	  30.2
Wong-Shi-Kong            	 115.1	  30.2
Hwang-shik-kang          	 115.1	  30.2
Huangshigang             	 115.1	  30.2
Collison Island          	 115.1	  30.3
Xinyuzhou                	 115.1	  30.3
Pook Island              	 115.1	  30.3
Daijiazhou Island        	 115.1	  30.3
Ten Foot Rock            	 114.9	  30.4
Hwangchow                	 114.9	  30.4
Huangzhou                	 114.9	  30.4
Squeeze Island           	 114.8	  30.6
Junling Cun              	 114.8	  30.6
Gravener Island          	 114.8	  30.6
Off Tuanfeng             	 114.8	  30.6
Willis Island            	 114.8	  30.6
Off Tuanfeng             	 114.8	  30.6
Porpoise Bluff           	 114.7	  30.6
West of Huarong          	 114.7	  30.6
Shako Village            	 114.6	  30.6
near Longkou             	 114.6	  30.6
Huquang Channel          	 114.4	  30.7
North of Bouncer Island  	 114.4	  30.7
Bouncer Island           	 114.4	  30.7
Tian Xing Xiang          	 114.4	  30.7
Hankow                   	 114.3	  30.6
Wuhan                    	 114.3	  30.6
Hwang-Chau               	 114.2	  30.5
Hanyang                  	 114.2	  30.5
Kin-Kow                  	 114.1	  30.3
King-Kau                 	 114.1	  30.3
Jinkou                   	 114.1	  30.3
Jiangxia                 	 114.1	  30.3
Mei-Tau-Chui             	 114.1	  30.3
Meitau Chui              	 114.1	  30.3
near Hannan              	 114.1	  30.3
Pae-Cho                  	 113.9	  30.2
Paechu                   	 113.9	  30.2
Paizhou Wanzhen          	 113.9	  30.2
Sang-Pai Chu             	 114.0	  30.2
off Paechu               	 114.0	  30.2
Hau-Chin-Kwang           	 114.1	  30.1
Panjiawanzhen            	 114.1	  30.1
Ashby Island             	 113.9	  30.0
Baishazhou Island        	 113.9	  30.0
Ku-Chi                   	 113.8	  29.9
Kuchi                    	 113.8	  29.9
Near Longkouchen         	 113.8	  29.9
Lungkow                  	 113.8	  29.9
Longkouchen              	 113.8	  29.9
Jau Kow                  	 113.6	  29.9
How Chow                 	 113.6	  29.9
Lau Chow Tau             	 113.6	  29.9
Yaokou                   	 113.6	  29.9
Pao Ta Chow              	 113.6	  29.9
Chibizhen                	 113.6	  29.9
Tuming Point             	 113.5	  29.8
near Huanggai Huzhen     	 113.5	  29.8
Sing Ti Reach            	 113.5	  29.8
Honghu                   	 113.5	  29.8
Sian-Ho-Kwang            	 113.3	  29.6
near Ruxizhen            	 113.3	  29.6
Jingsee                  	 113.3	  29.6
Yangxi                   	 113.3	  29.6
Chenglin                 	 113.1	  29.4
Ching Ling               	 113.1	  29.4
Chen Lin                 	 113.1	  29.4
Chin Lin                 	 113.1	  29.4
Chin Lin Sein            	 113.1	  29.4
Ching Dong Crossing      	 113.1	  29.4
Yueyang                  	 113.1	  29.4
Youchou                  	 113.1	  29.4
Yo-Chau                  	 113.1	  29.4
Yochau                   	 113.1	  29.4
Yueyang                  	 113.1	  29.4
Low Ming Tan             	 112.8	  28.7
Baihuxiang               	 112.8	  28.7
Siang-Yin                	 112.9	  28.7
Xiangyin                 	 112.9	  28.7
Changsha                 	 113.0	  28.2
Chang-sha                	 113.0	  28.2
Changsha                 	 113.0	  28.2
Fanchi Point             	 113.0	  29.5
West of Junshan          	 113.0	  29.5
Low Point                	 112.9	  29.6
near Hongshantouchen     	 112.9	  29.6
Shang-Chai-Wan           	 113.0	  29.8
Shangchewanzhen          	 113.0	  29.8
Brine Bend               	 112.9	  29.7
Opposite Changning       	 112.9	  29.7
Hong Kong Reach          	 112.9	  29.8
Kinlee Transit           	 112.9	  29.8
Near Jianli              	 112.9	  29.8
Kin Fin                  	 112.9	  29.8
near Jianli              	 112.9	  29.8
Sin Ho Kau               	 112.6	  29.7
Sinho-Kow                	 112.6	  29.7
Near Tashiyizhen         	 112.6	  29.7
Luikikow                 	 112.6	  29.7
Tiaoguanzhen             	 112.6	  29.7
Tiauhienkau              	 112.6	  29.8
Xiaohekouzhen            	 112.6	  29.8
Hou Kin Kow              	 112.6	  29.8
near Xiaohekou           	 112.6	  29.8
Temple Hill Bend         	 112.6	  29.8
off Beixiongjia Dou      	 112.6	  29.8
Kwang Ying               	 112.5	  29.8
near Dongshengzhen       	 112.5	  29.8
Skipper Point            	 112.4	  29.8
Opposite Shishou         	 112.4	  29.8
Sunday Island            	 112.4	  29.8
Opposite Wenjiatai       	 112.4	  29.8
Wanhai                   	 112.4	  29.9
Hoia                     	 112.4	  30.0
Hohia                    	 112.4	  30.0
Hohi                     	 112.4	  30.0
Hujia                   	 112.4	  30.0
Jiangling               	 112.4	  30.0
Tu-Ki-Chau               	 112.3	  30.1
Ma-Ta-Chi                	 112.7	  30.1
Majiazhaixiang           	 112.7	  30.1
Shasi                    	 112.2	  30.3
Shaze                    	 112.2	  30.3
Shazhe                   	 112.2	  30.3
Shashi                   	 112.2	  30.3
Taiping Chau             	 112.2	  30.3
Taiping Koucun           	 112.2	  30.3
Shitaoutsze              	 112.0	  30.3
Shitaozi                 	 112.0	  30.3
Ta-Ho-Kau                	 112.0	  30.3
near Zhangjiahe          	 112.0	  30.3
Kiangkow                 	 111.9	  30.4
near Qixingtaizhen       	 111.9	  30.4
Tungtse                  	 111.7	  30.4
near Dongshizhen         	 111.7	  30.4
Grant Point              	 111.6	  30.3
off Chendianzhen         	 111.6	  30.3
Chi-Kiang                	 111.5	  30.3
Zhichengzhen             	 111.5	  30.3
Pih-Yang                 	 111.5	  30.4
Baiyangzhen              	 111.5	  30.4
Itu Rocks                	 111.4	  30.4
near Gaobazhouzhen       	 111.4	  30.4
Hung-Hwa-Kau             	 111.4	  30.5
Honghuataozhen           	 111.4	  30.5
Ichang                   	 111.3	  30.7
Yichang                  	 111.3	  30.7
Active Pass              	-123.3	  48.9  # Canada
Addenbroke Island        	-127.8	  51.6  # Addenbroke Island Lighthouse
Addenbrook Island        	-127.8	  51.6
Alert Bay                	-126.9	  50.6  # Town on Cormorant I.
Amphitrite Point         	-125.5	  48.9  # Amphitrite Point Lighthouse
Awaq                     	-128.0	  70.6
Baillie Islands          	-128.2	  70.6
Ballanes Island          	-124.2	  49.4
Ballenas Island          	-124.2	  49.4  # Ballenas Island Lighthouse
Banks Island             	-121.5	  72.8
Banks Land               	-121.5	  72.8
Baring Land              	-121.5	  72.8
Blinkhorn Island         	-126.8	  50.5
Boat Bluff               	-128.5	  52.6  # Boat Bluff Lighthouse
Bonilla Island           	-130.6	  53.5  # Bonilla Island Lighthouse
Bonilla Point            	-124.7	  48.6
Boundary Pass            	-123.1	  48.7
Broughton Strait         	-127.0	  50.6
Brown Point              	-130.4	  70.2
Butterworth Rocks        	-131.0	  54.2  # Butterworth Rocks Light
Calvert Point            	-130.1	  53.9
Camp Island              	-128.1	  52.1
Camp Point               	-129.8	  53.7
Cape Bathurst            	-128.0	  70.6
Cape Beale               	-125.2	  48.8  # Cape Beale Lighthouse
Cape Brown               	-130.4	  70.2
Cape Caution             	-127.8	  51.2
Cape Cook                	-127.9	  50.1
Cape Dalhousie           	-129.7	  70.2
Cape Lazo                	-124.9	  49.7
Cape Mudge               	-125.2	  50.0  # Cape Mudge Lighthouse
Cape Parry               	-124.7	  70.2
Cape Peary               	-124.7	  70.2
Cape Perry               	-124.7	  70.2
Cape Sabine              	 -74.3	  78.7
Cape Scott               	-128.4	  50.8  # Cape Scott Lighthouse
Cape York                	 -87.0	  73.8
Cecil Patch              	-130.3	  54.1  # Cecil Patch Light
Chain Islands            	-125.3	  50.2
Chained Islands          	-125.3	  50.2
Chatham Point            	-125.4	  50.3  # Chatham Point Lighthouse
Christie Passage         	-127.6	  50.8
Clark Point              	-127.9	  51.4
Clew Nugget Island       	-129.7	  53.7
Cogmollet Bay            	-133.6	  69.5
Cormorant Island         	-126.9	  50.6
Cracroft Islands         	-126.3	  50.5
Dall Rocks               	-128.2	  52.2
Discovery Island         	-123.2	  48.4  # Discovery Island Lighthouse
Discovery Passage        	-125.4	  50.2
Dixon Entrance           	-132.0	  54.4
Dolphin Strait           	-116.0	  69.1
Dolphin and Union Strait 	-116.0	  69.1
Dryad Point              	-128.1	  52.2  # Dryad Point Lighthouse
East Point               	-123.0	  48.8  # East Point Lighthouse
Egg Island               	-127.8	  51.2  # Egg Island Lighthouse
Ella Point               	-126.8	  50.5
Ellice Island            	-135.8	  69.1
Ellis Island             	-135.8	  69.1
Entrance Island          	-123.8	  49.2  # Entrance Island Lighthouse
Esteban Point            	-126.5	  49.4
Estevan Point            	-126.5	  49.4  # Estevan Point Lighthouse
Fitz Hugh Sound          	-127.9	  51.7
Fitzhugh Sound           	-127.9	  51.7
Flora Islet              	-124.6	  49.5
Fog Island               	-127.9	  52.0
Fog Rocks                	-127.9	  52.0
Franklin Bay             	 -64.5	  81.6
Fraser Reach             	-128.8	  53.2
Galetos Channel          	-127.8	  50.9
Garry Island             	-135.7	  69.4
Geary Island             	-135.7	  69.4
Georgina Point           	-123.3	  48.9  # Active Pass Lighthouse
Goletas Channel          	-127.8	  50.9
Gordon Channel           	-127.6	  50.9
Graham Reach             	-128.6	  53.1
Green Island             	-130.7	  54.6  # Green Island Lighthouse
Greenville Channel       	-129.8	  53.7
Haddington Island        	-127.0	  50.6
Haddington Reefs         	-127.0	  50.6
Hanmer Island            	-130.7	  54.6  # Hanmer Island Light
Hecate Strait            	-131.0	  53.0
Helmcken Island          	-125.9	  50.4
Herbert Reef             	-130.2	  54.0  # Herbert Reef Light
Herschel Island          	-139.1	  69.6
Holland Rock             	-130.4	  54.2  # Holland Rock Lighthouse
Holliday Island          	-130.8	  54.6  # Holliday Island Light
Holliday Passage         	-130.7	  54.6
Ice House                	-128.2	  70.6
Idle Point               	-128.3	  52.2
Idol Point               	-128.3	  52.2
Ivory Island             	-128.4	  52.3  # Ivory Island Lighthouse
Jane Island              	-128.5	  52.6
Johnstone Strait         	-126.1	  50.5
Jorken Point             	-128.5	  52.4
Jorkins Point            	-128.5	  52.4
Juan De Fuca Strait      	-123.6	  48.2
Kaiete Point             	-128.0	  52.1
Kelp Reefs               	-123.2	  48.5
Kelpie Point             	-128.0	  51.7
Kingcombe Point          	-128.9	  53.3
Kingcome Point           	-128.9	  53.3
Kingcorne Point          	-128.9	  53.3
Klewnuggit Island        	-129.7	  53.7
Kogmullit Bay            	-133.6	  69.5
Kugmallit Bay            	-133.6	  69.5
Lady Franklin Bay        	 -64.5	  81.6
Lama Passage             	-128.1	  52.1
Langdon Bay              	-125.4	  69.4
Langton Bay              	-125.4	  69.4
Lawyer Island            	-130.3	  54.1  # Lawyer Island Light
Lennard Island           	-125.9	  49.1  # Lennard Island Lighthouse
Lowe Inlet               	-129.6	  53.5
Lucy Island              	-130.6	  54.3  # Lucy Island Lighthouse
Masterman Islands        	-127.4	  50.8
McLoughlin Bay           	-128.1	  52.1
Milbanke Sound           	-128.6	  52.3
Milly Island             	-126.1	  50.5
Napier Point             	-128.1	  52.1
Noble Islets             	-127.6	  50.8
Nuvorak Point            	-130.4	  70.2
Oyster Bay               	-125.2	  49.9
Pachena Point            	-125.1	  48.7  # Pachena Point Lighthouse
Pauline Cove             	-138.9	  69.6
Pine Island              	-127.7	  51.0  # Pine Island Lighthouse
Point Cumming            	-129.1	  53.3
Pointer Island           	-128.0	  52.1
Prince Albert Land       	-117.0	  72.5
Prince Albert Peninsula  	-117.0	  72.5
Prince Leboo Island      	-131.0	  54.5
Pulteney Point           	-127.2	  50.6  # Pulteney Point Lighthouse
Queen Charlotte Sound    	-128.5	  51.5
Race Point               	-125.3	  50.1
Race Rocks               	-123.5	  48.3  # Race Rocks Lighthouse
Red Cliff                	-128.6	  53.1
Redcliff Point           	-128.6	  53.1
Regatta Rocks            	-128.1	  52.2
Ripple Point             	-125.6	  50.4
Ripple Rock              	-125.3	  50.1  # Ripple Rock removal in 1958
Robb Point               	-128.4	  52.3
Rock Point               	-125.5	  50.4
Rogers Point             	-129.8	  53.7
Safety Cove              	-127.9	  51.5  # On Calvert I.
Safety Point             	-127.9	  51.5
Sarah Island             	-128.5	  52.8
Scarlett Point           	-127.6	  50.9  # Scarlett Point Lighthouse
Sea Egg Rocks            	-124.3	  49.5
Seal Rocks               	-130.8	  54.0  # Seal Rocks Light
Serpent Point            	-128.0	  52.1
Seymour Narrows          	-125.3	  50.1
Sheringham Point         	-123.9	  48.4  # Sheringham Point Lighthouse
Sister Islets            	-123.9	  48.4  # Sister Islets Lighthouse
Solander Island          	-127.9	  50.1
Storm Islands            	-127.7	  51.0
Story Point              	-128.1	  52.1
Strait of Georgia        	-123.8	  49.3
Thrasher Rock            	-123.7	  49.1
Tolmie Channel           	-128.5	  52.8
Trial Islands            	-123.3	  48.4  # Trial Islands Lighthouse
Triangle Island          	-129.1	  50.9  # Triangle Island Lighthouse
Triple Islands           	-130.9	  54.3  # Triple Islands Lighthouse
Trivet Point             	-129.0	  53.3
Trivett Point            	-129.0	  53.3
Union Passage            	-129.4	  53.4
Vancouver Island         	-125.7	  49.7
Vancouver Rock           	-128.5	  52.4
Vansittart Point         	-125.8	  50.4
Victoria Island          	-107.8	  70.4
Watson Rock              	-130.2	  53.9
Whale Bluffs             	-127.5	  70.4
Whale Cliff              	-127.5	  70.4
Wollaston Land           	-115.2	  69.7
Wollaston Peninsula      	-115.2	  69.7
Yellow Bluff             	-127.0	  50.6
Adak Island              	-176.6	  51.8  # Alaska
Adugak Island            	-169.2	  52.9
Adugak Rock              	-169.2	  52.9
Akun Head                	-165.6	  54.3
Akun Island              	-165.5	  54.2
Akutan                   	-165.8	  54.1
Akutan Bay               	-165.7	  54.2
Akutan Island            	-165.9	  54.1
Akutan Point             	-165.7	  54.1
Alaid Island             	 173.9	  52.8
Albatross Bank           	-152.5	  56.5
Alimuda Bay              	-167.3	  53.4
Amak Island              	-163.1	  55.4
Amaknak Island           	-166.5	  53.9
Amchitka Island          	 178.9	  51.6
Amelius Island           	-133.9	  56.2
Anaiuliak                	-168.9	  53.0
Anangouliak              	-168.9	  53.0
Anangula Island          	-168.9	  53.0
Ananiuliak Island        	-168.9	  53.0
Anayulyak                	-168.9	  53.0
Andrionica Island        	-160.1	  55.3
Andronica Island         	-160.1	  55.3
Angle Point              	-131.4	  55.2
Apavawook Cape           	-168.9	  63.1
Arch Point               	-161.9	  55.2
Arch Rock                	-166.6	  53.9
Atka Island              	-174.4	  52.1
Attu Island              	 172.9	  52.9
Bank Island              	-132.6	  56.5
Baralof Bay              	-160.6	  55.2
Barnes Point             	-177.7	  51.8
Barrow                   	-156.8	  71.3
Barter Island            	-143.7	  70.1
Barwell Island           	-149.3	  59.9
Bear Island              	-173.1	  60.7
Beauclerc Island         	-133.8	  56.3
Belkofski Point          	-162.1	  55.1
Black Rock               	-131.1	  55.0
Blank Islands            	-131.6	  55.3
Blossom Shoals           	-161.9	  70.4
Boat Rock                	-130.8	  54.8
Bold Cape                	-162.2	  55.0
Brower's Station         	-156.8	  71.3
Buldir Island            	 175.9	  52.4
Caamano Point            	-132.0	  55.5
Caines Head              	-149.4	  60.0
Cape Adagdak             	-176.6	  52.0
Cape Alitak              	-154.3	  56.9
Cape Anderson            	-168.9	  63.1
Cape Chacon              	-132.0	  54.7
Cape Chagak              	-168.2	  53.5
Cape Cheerful            	-166.7	  54.0
Cape Chiniak             	-152.2	  57.6
Cape Decision            	-134.1	  56.0
Cape Elizabeth           	-166.2	  68.9
Cape Field               	-167.9	  53.4
Fort Glenn               	-167.9	  53.4
Cape Golovnin            	-166.8	  68.3
Cape Halkett             	-152.2	  70.8
Cape Hallet              	-152.2	  70.8
Cape Hinchinbrook        	-146.6	  60.2
Cape Kalekhta            	-166.4	  54.0
Cape Kalekta             	-166.4	  54.0
Cape Kovrizhka           	-167.2	  53.9
Cape Lisbon              	-166.2	  68.9
Cape Lisburne            	-166.2	  68.9
Cape Lizbond             	-166.2	  68.9
Cape Muzon               	-132.7	  54.7
Cape Nome                	-165.0	  64.4
Cape Pankof              	-163.1	  54.7
Cape Pitt                	-153.1	  70.9
Cape Saint Elias         	-144.6	  59.8
Cape Sarichef            	-164.9	  54.6
Cape Seppings            	-165.1	  68.0
Cape Seppins             	-165.1	  68.0
Cape Smith               	-156.8	  71.3
Cape Smyth               	-156.8	  71.3
Cape Smythe              	-156.8	  71.3
Cape Spencer             	-136.6	  58.2
Cape Starr               	-169.0	  52.9
Cape Sudak               	-177.6	  51.9
Cape Tanak               	-168.0	  53.5
Cape Tangent             	-155.1	  71.2
Cape Tolstoi             	-161.5	  55.4
Cape Uyak                	-154.3	  57.6
Cape Wedge               	-159.9	  55.3
Cascade Point            	-169.6	  56.5
Cathedral Rocks          	-166.9	  53.7
Channel Islands          	-145.8	  60.6
Chatham Strait           	-134.6	  57.0
Chernofski               	-167.6	  53.4
Chernofski Point         	-167.6	  53.4
Chirikof Island          	-155.6	  55.8
Chukinuksak Point        	 172.7	  52.8
Chuniksak Point          	 172.7	  52.8
Chunisak Point           	 172.7	  52.8
Clarence Strait          	-132.6	  56.0
Coal Mine                	-165.1	  68.9
Coal Vein                	-165.1	  68.9
Cone Hill                	-170.4	  57.2
Constantine Harbor       	 179.3	  51.4
Cooper Island            	-155.7	  71.2
Cooper Islands           	 173.2	  53.0
Cooper's Station         	-166.7	  68.3
Cordova                  	-145.8	  60.5
Corwin Bluff             	-165.1	  68.9
Corwin Coal Mine         	-165.1	  68.9
Cross Sound              	-136.5	  58.2
Cutter Point             	-167.5	  53.4
Cutter Rocks             	-131.5	  55.3
Dalnoi Point             	-169.8	  56.6
Dean's Inlet             	-155.4	  71.0
Dease Inlet              	-155.4	  71.0
Deer Island              	-162.3	  54.9
Deer Passage             	-162.3	  55.0
Derby Point              	-168.8	  53.2
Diomede Islands          	-169.0	  65.8
Dixon Entrance           	-132.0	  54.4
Dolnoi Point             	-169.8	  56.6
Drew Point               	-153.9	  70.9
Dutch Harbor             	-166.5	  53.9
East Cape                	-168.9	  63.1
East Channel             	 173.3	  52.8
Massacre Bay            	 173.3	  52.8
Harrison's Bay          	-149.9	  70.5
Smith's Bay              	-153.9	  70.9
Eider Point              	-166.6	  54.0
English Bay              	-146.7	  60.3
Eye Opener               	-133.3	  56.4
Fairway Rock             	-168.8	  65.6
Faraway Rock             	-168.8	  65.6
Farway Rock              	-168.8	  65.6
Finger Shoal             	-176.6	  51.9
Flyaway Rock             	-168.8	  65.6
Foggy Cape               	-157.0	  56.5
Forester Island          	-133.5	  54.8
Forrester Island         	-133.5	  54.8
Fort Glenn               	-167.9	  53.4
Fox Island               	-162.4	  55.0
Gannet Rocks             	-176.6	  51.9
Garden Cove              	-169.5	  56.6
Goar's Island            	-172.7	  60.4
Goer's Island            	-172.7	  60.4
Goltsov Point            	 173.2	  53.0
Gore's Island            	-172.7	  60.4
Gower's Island           	-172.7	  60.4
Gravina Point            	-146.2	  60.6
Great Sitkin Island      	-176.1	  52.1
Guard Islands            	-131.9	  55.5
Gulf of Alaska           	-144.0	  57.0
Gull Rock                	-172.8	  60.2
Gull Rocks               	-172.8	  60.2
Hall Island              	-173.1	  60.7
Hanks Island             	-146.0	  60.6
Harrison Bay             	-152.1	  70.7
Head Rock                	-176.5	  51.9
Helm Rock                	-133.6	  56.4
Hid Reef                 	-131.7	  55.1
High Hill                	-168.9	  53.0
Hinchinbrook Island      	-146.5	  60.4
Hog Rocks                	-131.3	  55.2
Holtz Bay                	 173.2	  53.0
Hot Springs Bay          	-177.8	  51.8
Humpback Rock            	-152.2	  57.7
Icy Cape                 	-161.9	  70.3
Icy Strait               	-135.7	  58.3
Iliaski Island           	-161.9	  55.1
Iliuliuk Bay             	-166.5	  53.9
Illiuliuk Harbor         	-166.5	  53.9
Inian Islands            	-136.3	  58.2
Inner Iliasik Island     	-161.9	  55.1
Jabbertown               	-166.7	  68.3
Johnston Point           	-146.6	  60.5
Johnstone Point          	-146.6	  60.5
Kashega Bay              	-167.2	  53.5
Kashega Point            	-167.2	  53.5
Kayak Island             	-144.4	  59.9
Kelley's Station         	-156.8	  71.3
Kelly's House            	-156.8	  71.3
Kelly's Station          	-156.8	  71.3
Kelp Point               	-168.9	  53.0
Ketavie Point            	-170.3	  57.1
Ketchikan                	-131.7	  55.4
Key Reef                 	-132.8	  56.2
King Cove                	-162.3	  55.1
King Island              	-168.1	  65.0
King's Island            	-168.1	  65.0
Kitovi Point             	-170.3	  57.1
Kodiak                   	-152.4	  57.8
Kodiak Island            	-153.5	  57.4
Konig's Station          	-166.7	  68.3
Koriga Point             	-167.0	  54.0
Kotzebue Sound           	-162.8	  66.5
Krasni Point             	 173.1	  52.8
Krusenstern Island       	-168.9	  65.7
Kuluk Bay                	-176.6	  51.9
Kuluk Shoal              	-176.5	  51.9
Kupreanof Point          	-159.6	  55.6
Kurityien Anaiuliak Island	-168.9	  53.0
Lemesurier Island        	-136.1	  58.3
Lincoln Rock             	-132.7	  56.1
Little Diomede Island    	-168.9	  65.7
Little Sitkin Island     	 178.5	  52.0
Lord Rock                	-130.8	  54.7
Lost Harbor              	-165.6	  54.2
Makushin Bay             	-167.0	  53.7
Manning Point            	-143.5	  70.1
Mary Island              	-131.2	  55.1
Massacre Bay             	 173.2	  52.8
Matwi Island             	-172.7	  60.4
McArthur Reef            	-133.2	  56.4
Middle Ground Shoal      	-146.3	  60.5
Middleton Island         	-146.3	  59.4
Mitrofania Island        	-158.8	  55.9
Morgan Point             	-162.3	  55.0
Moss Cape                	-161.9	  55.1
Mountain Point           	-131.5	  55.3
Narrow Point             	-132.5	  55.8
Nevidiskof Bay           	 172.8	  52.8
Nevidiskov Bay           	 172.8	  52.8
Niblack Point            	-132.1	  55.5
Nikolski Bay             	-168.9	  53.0
Noatak River             	-162.5	  67.0
North Anchorage          	-169.6	  56.6
North Cape               	-170.5	  63.7
North Head               	-165.9	  54.2
North Inian Pass         	-136.4	  58.3
Nuchek                   	-146.7	  60.3
Nyman Spit               	-152.5	  57.7
Observatory Point        	-167.5	  53.4
Okee Point               	-168.8	  53.0
Oliktok Point            	-149.9	  70.5
Ooglamie                 	-156.8	  71.3
Orca Bay                 	-146.2	  60.6
Orca Inlet               	-145.9	  60.5
Otter Bight              	-167.8	  53.4
Otter Island             	-170.4	  57.0
Otter Point              	-167.8	  53.4
Pacific Shoal            	-151.9	  70.8
Passage Islands          	-169.0	  65.8
Pavlof Islands           	-161.7	  55.1
Peard Bay                	-158.8	  70.8
Pearl Bay                	-158.8	  70.8
Phipps Point             	-146.6	  60.4
Pilot Rock               	-149.5	  59.7
Pinnacle Island          	-172.8	  60.2
Pinnacle Rock            	-172.8	  60.2
Pitt Point               	-153.1	  70.9
Point Adolphus           	-135.8	  58.3
Point Augusta            	-134.9	  58.0
Point Baker              	-133.6	  56.4
Point Barrow             	-156.5	  71.4
Point Belcher            	-159.7	  70.8
Point Belgium            	-159.7	  70.8
Point Cooper             	-155.7	  71.2
Point Crowley            	-134.3	  56.1
Point Franklin           	-158.8	  70.9
Point Gardner            	-134.6	  57.0
Point Hope               	-166.8	  68.3
Point Hope (city)        	-166.7	  68.3
Point McCartey           	-131.7	  55.1
Point Saint Albans       	-134.0	  56.1
Point Smith              	-156.8	  71.3
Point Winslow            	-131.2	  55.1
Porpoise Rocks           	-146.7	  60.3
Port Clarence            	-166.7	  65.2
Port Clearance           	-166.7	  65.2
Port Etches              	-146.6	  60.3
Port Moller              	-160.6	  56.0
Port Moore               	-156.4	  71.4
Potter Rock              	-131.6	  55.3
Priest Rock              	-167.0	  53.8
Princess Head            	-166.4	  54.0
Pumicestone Bay          	-167.1	  53.5
Pyramid Point            	-144.4	  59.9
Race Rocks               	-165.7	  54.1
Raven Point              	-164.8	  54.6
Refuge Inlet             	-157.0	  71.1
Refuge Station           	-156.8	  71.3
Resurrection Bay         	-149.4	  60.0
Return Islands           	-148.9	  70.5
Return Reef              	-148.9	  70.5
Revillagagedo Channel    	-131.1	  55.1
Revillagigedo Channel    	-131.1	  55.1
Round Point              	-132.7	  56.3
Rudisell Reef            	-168.9	  53.0
Rugged Island            	-149.4	  59.9
Saint Diomede Islands    	-169.0	  65.8
Saint George Island      	-169.6	  56.6
Saint Matthew Island     	-172.7	  60.4
Saint Paul Harbor        	-152.4	  57.8
Saint Paul Island        	-170.3	  57.1
Saint Paul              	-170.3	  57.1
St Diomede Islands      	-169.0	  65.8
St George Island        	-169.6	  56.6
St George              	-169.6	  56.6
St Matthew              	-172.7	  60.4
St Matthew Island       	-172.7	  60.4
St Paul Harbor          	-152.4	  57.8
St Paul Island          	-170.3	  57.1
St Paul                 	-170.3	  57.1
Savoonga Point           	-170.5	  63.7
Scotch Cap               	-164.8	  54.4
Sea Lion Rock            	-170.3	  57.1
Seahorse Islands         	-158.7	  70.9
Seal Cape                	-164.7	  54.4
Seal Rocks               	-149.6	  59.5
Sealion Rocks            	-151.8	  58.3
Semidi Islands           	-156.7	  56.1
Seward                   	-149.4	  60.1
Shelikof Strait          	-154.9	  57.4
Sheshalik                	-162.8	  67.0
Ship Island              	-132.2	  55.6
Ship Rock                	-132.2	  55.6
Sitkinak Strait          	-154.0	  56.7
Smith Bay                	-154.4	  70.9
Snow Passage             	-132.9	  56.3
South Passage Point      	-134.9	  57.8
Southwest Point          	-170.4	  57.2
Spasski Island           	-135.3	  58.1
Spire Island             	-131.5	  55.3
Spit Rock                	-172.8	  60.4
Split Rock               	-172.8	  60.4
Squaw Harbor             	-160.6	  55.2
Steamer Point            	-132.7	  56.2
Stikine Strait           	-132.6	  56.3
Sugarloaf Mountain       	-172.6	  60.3
Sumner Strait            	-133.5	  56.4
Swallow Head             	-176.2	  52.1
Sweeper Cove             	-176.6	  51.9
Tachinisok Inlet         	-158.3	  70.8
Tanaga Island            	-177.9	  51.8
Tangent Point            	-155.1	  71.2
Temnac Bay               	 173.0	  52.8
The Eye Opener           	-133.3	  56.4
The Inlet                	-160.0	  70.6
The Rock                 	-168.8	  65.6
Theodore Point           	 172.9	  52.8
Thin Point               	-162.6	  55.0
Tigalda Island           	-165.1	  54.1
Tolstoi Point            	-169.5	  56.6
Tongass Narrows          	-131.8	  55.4
Tonki Cape               	-152.0	  58.4
Tree Point               	-130.9	  54.8
Trunk Point              	-177.8	  51.8
Twin Islands             	-131.2	  55.1
Ugak Island              	-152.3	  57.4
Ugamak Island            	-164.8	  54.2
Ukivok Island            	-168.1	  65.0
Ukivuk King Island       	-168.1	  65.0
Ukolnoi Island           	-161.6	  55.2
Ulakhta Head             	-166.5	  53.9
Ulakta Head              	-166.5	  53.9
Uliaga Island            	-169.8	  53.1
Ulyaga Island            	-169.8	  53.1
Umga Island              	-162.7	  54.8
Umnak Island             	-168.4	  53.2
Unalaska Bay             	-166.5	  53.9
Unalaska Island          	-166.7	  53.7
Unga Island              	-160.7	  55.3
Unga Spit                	-160.7	  55.4
Unimak Island            	-164.2	  54.8
Utekavik                 	-156.8	  71.3
Utkiavie                 	-156.8	  71.3
Vank Island              	-132.6	  56.5
Vicknefski Rock          	-133.0	  56.4
Village Cove             	-170.3	  57.1
Volcano Bay              	-167.1	  53.8
Wainwright Inlet         	-160.0	  70.6
Walakpa Bay              	-157.0	  71.1
Wedge Point              	-167.4	  53.4
Westdahl Rock            	-162.8	  54.6
Whale Point              	-170.3	  57.1
Whaling Station          	-165.8	  54.1
Wide Bay                 	-166.6	  54.0
Womens Bay               	-152.5	  57.7
Wooded Island            	-147.4	  59.9
Woody Inlet              	-158.3	  70.8
Wrangell Island          	-132.2	  56.3
Zapadni Point            	-170.3	  57.1
Zeto Point               	-176.6	  51.9
Alceste I                	 122.6	  37.4  # China
Bombay                   	  72.8	  19.0
Canton                   	 113.6	  22.8
Cap Padaran              	 109.0	  11.4
Vietnam                  	 109.0	  11.4
Digue I.                	  55.8	  -4.6
Hoi Hau                  	 113.1	  22.7
Haikou                   	 113.1	  22.7
Hong Kong                	 114.2	  22.3
Kamrahn Bay              	 109.2	  11.9
Cam Ranh                 	 109.2	  11.9
Vietnam                  	 109.2	  11.9
La Digue I.             	  55.8	  -4.6
Seychelles               	  55.5	  -4.7
Maldives                 	  73.5	   4.2
Pakhoi                   	 109.1	  21.5
Pei-hai                  	 109.1	  21.5
China                    	 109.1	  21.5
Recif I.                 	  55.8	  -4.6
Seychelles               	  55.8	  -4.6
Shanghai                 	 121.5	  31.2
Swatow                   	 116.7	  23.4
Shantou                  	 116.7	  23.4
China                    	 116.7	  23.4
Tourane Bay              	 108.2	  16.1
Da Nang                  	 108.2	  16.1
Vietnam                  	 108.2	  16.1
Wei Hai Wei              	 122.1	  37.5
Wei-hai-wei              	 122.1	  37.5
Cape Atholl              	 -69.6	  76.4  # Greenland
Cape York                	 -66.5	  75.9
Comanche Bay             	 -40.3	  65.1
Conical Rock             	 -68.7	  76.1
Disko Bay                	 -52.0	  69.0
Disko Bugt               	 -52.0	  69.0
Disko Island             	 -53.5	  69.8
Disko Oer                	 -53.5	  69.8
Godhavn                  	 -53.5	  69.2
Igannaq                  	 -68.7	  76.1
Igtip Kangertiva         	 -40.3	  65.1
Innaanganeq              	 -66.5	  75.9
Ivanganek                	 -66.5	  75.9
Kangaarsuk               	 -69.6	  76.4
Kap Atholl               	 -69.6	  76.4
Kap York                 	 -66.5	  75.9
Kekertarsuak             	 -53.5	  69.2
Kikertarsuak             	 -53.5	  69.8
Melville Monument        	 -59.4	  75.8
Perlernerit              	 -66.5	  75.9
Pikiitsi                 	 -40.6	  64.2
Pikiutdleq               	 -40.8	  65.0
Qeqertarsuaq             	 -53.5	  69.8  # Island
Qeqertarsuaq             	 -53.5	  69.2  # Town
Qeqertarsuup Tunua       	 -52.0	  69.0
Wolstenholme Island      	 -70.0	  76.4
Wolstenholme             	 -70.0	  76.4
Ainovskie Ostrovo        	  31.6	  69.8  # Russian
Anadair Sea              	-178.0	  64.0
Anadir                   	 177.5	  64.7
Anadir Bay               	-178.0	  64.0
Anadir River             	 177.6	  64.7
Anadir Sea               	-178.0	  64.0
Anadyr                   	 177.5	  64.7
Anadyr Bay               	-178.0	  64.0
Anadyr River             	 177.6	  64.7
Anadyr Sea               	-178.0	  64.0
Anadyrsky Liman          	-178.0	  64.0
Arakam Id                	-172.4	  64.8
Archangel Bay            	 179.2	  62.4
Archangel Gabriel Bay    	 179.2	  62.4
Avacha Bay               	 158.6	  52.9
Avachinskaya Guba        	 158.6	  52.9
Avatcha Bay              	 158.6	  52.9
Aynovskiye Ostrova       	  31.6	  69.8
Bald Head                	-173.4	  64.3
Ball's Head              	-173.4	  64.3
Banka Geral'd            	-171.2	  70.5
Bay of Gabriel           	 179.2	  62.4
Bay of Holy Cross        	-179.2	  66.0
Behring                  	 166.3	  55.0
Behring Island           	 166.3	  55.0
Bering Island            	 166.3	  55.0
Big Diomede Island       	-169.1	  65.8
Big Island               	-172.4	  64.8
Brothers                 	 158.7	  52.9
Bukhta Emma              	-173.2	  64.4
Bukhta Gavriila          	 179.2	  62.4
Bukhta Kitolovnaya       	-175.9	  65.1
Bukhta Komsomol'skaya    	-173.2	  64.4
Bukhta Preobrazheniya    	-175.4	  64.8
Bukhta Providence        	-173.3	  64.4
Bukhta Provideniya       	-173.3	  64.4
Bukhta Puoten            	-170.5	  65.9
Bukhta Ridder            	-176.0	  65.4
Bukhta Rodzhers          	-178.4	  71.0
Bukhta Rodzhersa         	-178.4	  71.0
Bukhta Rogers            	-178.4	  71.0
Bukhta Rudder            	-176.0	  65.4
Bukhta Ruddera           	-176.0	  65.4
Bukhta Rudera            	-176.0	  65.4
Bukhta Tkachen           	-172.8	  64.5
Bukhta Ugol'naya         	 179.4	  63.0
Burney Island            	-174.6	  67.5
Cape Aggen               	-175.4	  64.8
Cape Apoupinskoi         	 174.3	  61.8
Cape Chaplin             	-172.2	  64.4
Cape East                	-169.7	  66.1
Cape Hawaii              	-177.9	  71.0
Cape Navarin             	 179.1	  62.3
Cape Navarino            	 179.1	  62.3
Cape Naveriene           	 179.1	  62.3
Cape North               	-179.5	  68.9
Cape Nos                 	-173.1	  64.2
Cape Olyutorsk           	 170.3	  59.9
Cape Otorsk              	 170.3	  59.9
Cape Pounpinskoi         	 174.3	  61.8
Cape Saint Thaddeus      	 179.6	  62.7
Cape Serdzekamen         	-171.6	  66.9
Cape Serge               	-171.6	  66.9
Cape Surds               	-171.6	  66.9
Cape Surge               	-171.6	  66.9
Cape Thaddeus            	 179.6	  62.7
Cape Ulahapen            	-173.9	  64.4
Cape Unicorn             	-170.6	  66.4
Cape Unikan              	-170.6	  66.4
Cape Vankarem            	-175.8	  67.8
Cape Wankarem            	-175.8	  67.8
Chukotski Nose           	-173.1	  64.2
Commander Islands        	 167.0	  55.0
Corwin Island            	-172.8	  67.0
De Long Strait           	 176.2	  69.8
Dezhnevo                 	-169.9	  66.0
East Cape                	-169.7	  66.1
East Head                	-173.4	  64.3
East River               	-176.0	  67.8
Emma Harbor              	-173.2	  64.4
Emmatown                 	-169.9	  66.0
Enmitahin                	-169.9	  66.0
False Cape               	-170.2	  66.3
False East Cape          	-170.2	  66.3
Gavan' Emma              	-173.2	  64.4
Guba Arkhangela Gavriila 	 179.2	  62.4
Guba Gabriila            	 179.2	  62.4
Guba Gavriila            	 179.2	  62.4
Gulf of Anadyr           	-178.0	  64.0
Gulf of Saint Croix      	-179.2	  66.0
Herald Island            	-175.7	  71.4
Herald Reef              	-171.2	  70.5
Herald Shoal             	-171.2	  70.5
Holy Cross Bay           	-179.2	  66.0
Hooper's Island          	-172.8	  67.0
Immatown                 	-169.9	  66.0
India Point              	-172.2	  64.4
Indian Point             	-172.2	  64.4
Island of the Big River  	-174.6	  67.5
Isle of Carrolshotkey    	 164.2	  58.9
John Howland Bay         	-172.9	  64.3
Kaiaghinsky Island       	 164.2	  58.9
Kamcatska Sea            	-175.0	  60.0
Kamchatka Sea            	-175.0	  60.0
Kamni Tri Brata          	 158.7	  52.9
Kanag-Kinsky Island      	 164.2	  58.9
Karagin Island           	 164.2	  58.9
Kayne Id                 	-172.4	  64.8
Kivak                    	-172.9	  64.3
Kivik                    	-172.9	  64.3
Kola Inlet               	  33.4	  69.1
Kolintchin Island        	-174.6	  67.5
Koliuchin Bay            	-174.4	  66.8
Kolyuchin Bay            	-174.4	  66.8
Kolyuchinskaya Guba      	-174.4	  66.8
Komandorski Islands      	 167.0	  55.0
Komandorskiye Ostrova    	 167.0	  55.0
Kresta Bay               	-179.2	  66.0
Kresta Gulf              	-179.2	  66.0
Laguna Vankarem          	-176.0	  67.8
Little Island            	-172.6	  64.6
Little John Howland Village	-172.9	  64.3
Long Strait              	 176.2	  69.8
Marcus Bay               	-172.8	  64.5
Martin's Bay             	-172.8	  64.5
Masinka Bay              	-172.7	  64.8
Maska Island             	-178.0	  65.4
Masken Island            	-178.0	  65.4
Medny Island             	 167.7	  54.7
Mercury Harbor           	-176.0	  65.4
Mys Achchen              	-175.4	  64.8
Mys Barykova             	 179.4	  63.1
Mys Chaplina             	-172.2	  64.4
Mys Chukotskiy           	-173.1	  64.2
Mys Dezhneva             	-169.7	  66.1
Mys Faddeya              	 179.6	  62.7
Mys Fomy                 	 178.7	  71.0
Mys Gavai                	-177.9	  71.0
Mys Gil'der              	 178.6	  71.0
Mys Inchoun              	-170.2	  66.3
Mys Inchovyn             	-170.2	  66.3
Mys Intsova              	-170.2	  66.3
Mys Kriguygun            	-171.1	  65.5
Mys Lysaya Golova        	-173.4	  64.3
Mys Navarin              	 179.1	  62.3
Mys Nunyamo              	-170.6	  65.6
Mys Olyutorskiy          	 170.3	  59.9
Mys Opukhinskiy          	 174.3	  61.8
Mys Opukinskiy           	 174.3	  61.8
Mys Otto Shmidta         	-179.5	  68.9
Mys Rubikon              	 174.7	  61.9
Mys Serdiye Kamen'       	-171.6	  66.9
Mys Serdtse-Kamen'       	-171.6	  66.9
Mys Shmidta              	-179.5	  68.9
Mys Ulyakhpen            	-173.9	  64.4
Mys Unikyn               	-170.6	  66.4
Mys Vankarem             	-175.8	  67.8
North Head               	-170.6	  65.6
Ostrov Arakamchechen     	-172.4	  64.8
Ostrov Beringa           	 166.3	  55.0
Ostrov Erdmana           	-173.3	  64.6
Ostrov Geral'd           	-175.7	  71.4
Ostrov Geralda           	-175.7	  71.4
Ostrov Idlidlya          	-172.8	  67.0
Ostrov Itygran           	-172.6	  64.6
Ostrov Karaginskiy       	 164.2	  58.9
Ostrov Kolyuchin         	-174.6	  67.5
Ostrov Kosa Meechkyn     	-178.0	  65.4
Ostrov Litke             	-170.9	  65.6
Ostrov Mednyy            	 167.7	  54.7
Ostrov Ratmanova         	-169.1	  65.8
Ostrov Vrangelya         	-179.4	  71.2
Ostrova Aynovskiye       	  31.6	  69.8  # Ostrov Bolshoy Aynov Lighthouse
Ostrovnoy                	  39.5	  68.0
Pechenga Fiord           	  31.4	  69.6
Petropauloski            	 158.7	  53.0
Petropavlovsk Kamchatski 	 158.7	  53.0
Plover Bay               	-173.3	  64.4
Plover Land              	-179.4	  71.2
Plubber Bay              	-173.3	  64.4
Port Providence          	-173.3	  64.4
Port Rescue              	-176.0	  65.4
Proliv Longa             	 176.2	  69.8
Proliv Senyavina         	-172.7	  64.8
Providence Bay           	-173.3	  64.4
Puoten Bluff             	-170.5	  65.9
Ratmanof                 	-169.1	  65.8
Ratmanoff Island         	-169.1	  65.8
Reka Anadyr              	 177.5	  64.7
Reyd Plover              	-173.3	  64.4
Rocky Gulf               	 179.4	  63.0
Rodgers Harbor           	-178.4	  71.0
Rudder Bay               	-176.0	  65.4
Saint Lawrence Bay       	-171.1	  65.7
St Lawrence Bay          	-171.1	  65.7
Sand Point of the Holy Cross	-178.0	  65.4
Small Island             	-172.6	  64.6
Snug Harbor              	-173.3	  64.6
South Head               	-171.1	  65.5
Sunday Island            	-170.9	  65.6
Three Brothers           	 158.7	  52.9
Transfiguration Bay      	-175.4	  64.8
Uelen                    	-169.8	  66.2
Ugdnaya Bay              	 179.4	  63.0
Vankarem                 	-175.8	  67.8
Vankarem River           	-176.0	  67.8
Wellen                   	-169.8	  66.2
Whale Island             	-173.3	  64.6
Whalen                   	-169.8	  66.2
Whalers Bay              	-175.9	  65.1
Whalers Harbor           	-175.9	  65.1
Whaling                  	-169.8	  66.2
Wrangel Island           	-179.4	  71.2
Yukanskie                	  39.5	  68.0
Zaliv Kiguan             	-172.9	  64.3
Zaliv Kresta             	-179.2	  66.0
Zaliv Lavrentiya         	-171.1	  65.7
Zaliv Tkachen            	-172.8	  64.5
Cabo Falso               	-110.0	  22.9  # Mexico
Cape San Lazaro          	-112.3	  24.8
Cape San Lucas           	-109.9	  22.9
Cedros Island            	-115.2	  28.2
Cedros Mountain          	-115.2	  28.1
Natividad Island         	-115.2	  27.9
Point Tosca              	-111.7	  24.3
Aden                     	  45.1	  12.8  # East Africa
Amana I                  	  39.5	  -8.7
Bagamoyo port            	  38.9	  -6.4
Barakuni Island          	  39.8	  -7.7
Beira                    	  34.8	 -19.8
Boydu Island             	  39.5	  -7.9
Cape Delgado             	  40.6	 -10.7
Cabo Delgado             	  40.6	 -10.7
Cape Town                	  18.4	 -33.9
Chaki Chaki Bay          	  39.7	  -5.3
Chumbe Island           	  39.2	  -6.3
Dar-es-salaam            	  39.3	  -6.8
Delagoa Bay              	  32.7	 -26.0
Maputo Bay               	  32.7	 -26.0
Durban                   	  31.0	 -29.9
Port Natal               	  31.0	 -29.9
Fanjove I                	  39.6	  -8.6
Fungu Nyama              	  39.2	  -5.0
Fungu Tongone            	  39.1	  -5.3
Fungu Yasin              	  39.2	  -6.6
Gala Island              	  39.7	 -10.0
Gaze Bay                 	  39.5	  -4.5
Jewe Reef                	  39.5	  -8.7
Kibondo island           	  39.7	  -8.1
Kilindini               	  39.7	  -4.1
Mombasa                 	  39.7	  -4.1
Kisimayu                 	  42.5	   0.4
Kismayo                  	  42.5	   0.4
Kilwa Kisiwani           	  39.5	  -9.0
Kilwa Kivinje            	  39.4	  -8.8
Kivinge                  	  39.4	  -8.8
Kisiti                   	  39.4	  -4.7
Kiswere                  	  39.6	  -9.4
Koma I                   	  39.4	  -7.5
Konduchi                 	  39.2	  -6.7
Kwale Bay                	  39.3	  -5.0
Kwale I                  	  39.4	  -7.4
Lindi                    	  39.7	 -10.0
Machangi Reef            	  39.5	  -8.4
Makatumbe Is             	  39.3	  -6.8
Mange Reef               	  39.6	  -8.1
Maputo Bay               	  32.7	 -26.0
Delagoa Bay              	  32.7	 -26.0
Mazimbwa                 	  40.4	 -11.4
Mocimboa da Praia        	  40.4	 -11.4
Maziwi I                 	  39.1	  -5.5
Mbudya I                 	  39.3	  -6.7
Mchinga Bay              	  39.8	  -9.7
Mgau Mwania              	  40.0	 -10.1
Mikindani Bay            	  40.2	 -10.3
Mingoyo, Lindi River     	  39.6	 -10.1
Mkwaja                   	  38.9	  -5.8
Msasani Bay              	  39.3	  -6.7
Mongo I                  	  40.3	 -10.3
Moresby Point           	  39.9	  -7.6
Mafia I                 	  39.9	  -7.6
Mungopani                	  39.2	  -6.0
Mwamba Shundo            	  39.3	  -4.9
Mwamba Wamba I           	  39.3	  -4.9
Mwana Mwana              	  39.2	  -5.8
Niororo I                	  39.8	  -7.7
North Fanjove Island     	  39.5	  -7.3
Nymphe shoal             	  40.0	 -10.1
Nyuni I                  	  39.6	  -8.4
Okusa I                  	  39.6	  -8.3
Okuza                    	  39.6	  -8.3
Pangani Bay              	  39.0	  -5.4
Port Mombasa             	  39.6	  -4.1
Port Said                	  32.3	  31.3
Port Tewfik              	  32.6	  29.9
Tafiq                    	  32.6	  29.9
Pungume Island LH        	  39.3	  -6.4
Pungutiayu               	  39.4	  -4.7
Ras Banura               	  39.8	  -9.9
Ras Fungu                	  39.3	  -8.4
Ras Kanzi LH             	  39.6	  -7.0
Ras Kegomacha                 	  39.7	  -4.9
Pemba I                 	  39.7	  -4.9
Kigomasha                	  39.7	  -4.9
Ras Kipakoni             	  39.6	  -9.0
Ras Kisimani             	  39.6	  -8.0
Ras Makumbe              	  39.9	  -7.6
Ras Mkumbi               	  39.9	  -7.6
Moresby Point            	  39.9	  -7.6
Ras Matuso               	  39.6	  -8.9
Ras Miramba              	  39.5	  -8.8
Ras Sangamku             	  40.2	 -10.2
Ras Tikwiri              	  39.5	  -8.8
Rovuma Bay               	  40.5	 -10.4
Rukyira Bay              	  39.6	  -8.9
Saadani                  	  41.1	  -2.0
Sadani                   	  39.1	  -5.2
Saadani                  	  39.1	  -5.2
Salale                   	  39.3	  -7.8
Rufiji river            	  39.3	  -7.8
Sange Island             	  38.9	  -5.7
Sefo Reef                	  39.6	  -7.8
Shangani Shoal           	  40.2	 -10.2
Shungumbili I            	  39.3	  -7.7
Sii Island               	  39.3	  -4.7
Simaya Island            	  39.4	  -8.3
Simba Uranga             	  39.3	  -7.7
Simonstown               	  18.4	 -34.2
Songa Songa              	  39.5	  -8.5
Songo Songo              	  39.5	  -8.5
Sudi Bay                 	  40.0	 -10.1
Suez                     	  32.6	  30.0
Tambuzi Island           	  40.6	 -11.4
Tanga Bay                	  39.1	  -5.0
Tirene Bay               	  39.7	  -7.9
Tunghi Bay               	  40.6	 -10.8
Baia de Tunge            	  40.6	 -10.8
Tutia reef               	  39.7	  -8.1
Kwale Bay                	  39.3	  -5.0
Wasin Island             	  39.4	  -4.7
Yambe Island             	  39.2	  -5.1
Zanzibar                 	  39.2	  -6.2
Adra Lighthouse          	  -3.0	  36.8
Cape Agua                	  -1.9	  36.9
Alboran Island           	  -3.0	  35.9
Isla de Alboran          	  -3.0	  35.9
Alhucemas Lighthouse     	  -3.8	  35.3
Al Hoceima               	  -3.8	  35.3
Alicante                 	  -0.4	  38.4
Almeria                  	  -2.5	  36.8
Almina                   	  -5.3	  35.9
Aquilas                  	  -1.6	  37.4
Agilas                   	  -1.6	  37.4
Cape Baba                	  -4.3	  35.2
Cap Baba                 	  -4.3	  35.2
Cabo Baba                	  -4.3	  35.2
Cape Baba                	  26.1	  39.5
Baba Burnu               	  26.1	  39.5
Cape Bengut              	   3.9	  36.9
Cap Bengut               	   3.9	  36.9
Cap Benngut              	   3.9	  36.9
Betoya Bay               	  -3.4	  35.3
Baie Betoya              	  -3.4	  35.3
Cape Blanc               	   9.8	  37.3
Cap Blanc                	   9.8	  37.3
Ar Ras al Abya           	   9.8	  37.3
Ras el Abiadh            	   9.8	  37.3
Cape Bon                 	 -11.0	  37.1
Cape Bougaroni           	   6.5	  37.1
Cap Bougaroui            	   6.5	  37.1
Cap Bougaroun            	   6.5	  37.1
Seba Rouss               	   6.5	  37.1
Callaburras              	  -4.6	  36.5
Punta de Calaburras      	  -4.6	  36.5
Cani Rocks Lighthouse    	  10.1	  37.4
Iles Cani                	  10.1	  37.4
Dziret Likleb            	  10.1	  37.4
Cape Carbon              	   5.1	  36.8
Cap Carbon               	   5.1	  36.8
Cape Caxini              	   3.0	  36.8
Cap Caxines              	   3.0	  36.8
Cap Caxine               	   3.0	  36.8
Chapa                    	  -1.1	  37.6
Las Chapas               	  -1.1	  37.6
Cape Corbelin            	   4.4	  36.9
Cotella Point            	  -4.9	  35.4
Point Targa              	  -4.9	  35.4
Pointe Tarerha           	  -4.9	  35.4
Punta Cotelle            	  -4.9	  35.4
Ras el Targa             	  -4.9	  35.4
Cape de Fer              	   7.2	  37.1
Cap de Fer               	   7.2	  37.1
Ras el-Hadid             	   7.2	  37.1
Cape de Garde            	   7.8	  37.0
Cap de Garde             	   7.8	  37.0
Cape de Gardi            	   7.8	  37.0
Cape de Gata             	  -2.2	  36.7
El Cabo de Gata          	  -2.2	  36.7
Ras Eugela               	   9.7	  37.3
Ras Engela               	   9.7	  37.3
Cap Enghela              	   9.7	  37.3
Cape Riren               	   9.7	  37.3
Ras Angela               	   9.7	  37.3
Ras Enghela              	   9.7	  37.3
Ras Ennrhela             	   9.7	  37.3
Ra's Engela              	   9.7	  37.3
Point Europa             	  -5.3	  36.1
Punta Europa             	  -5.3	  36.1
Cape Ferrat              	  -0.4	  35.9
Ras el Mishat            	  -0.4	  35.9
Filfola Island           	  14.4	  34.8
Filfla Island            	  14.4	  34.8
Fratelli Rocks           	  15.3	  37.1
The Two Brothers Rocks   	  15.3	  37.1
Scoglio Due Fratelli     	  15.3	  37.1
Sicilian I Ru' Frati     	  15.3	  37.1
Galita Island            	   8.9	  37.5
Galite Island            	   8.9	  37.5
Gozo Island              	  14.2	  36.0
Calypso's Island         	  14.2	  36.0
Ghaudesh                 	  14.2	  36.0
Ghaudex                  	  14.2	  36.0
Gozzo Island             	  14.2	  36.0
Habibas Island           	  -1.1	  35.7
Hormigis Island          	  -0.7	  37.7
El Hormigon              	  -0.7	  37.7
Cape Ivi                 	   0.2	  36.1
Port Kelah               	  -2.1	  35.1
Port Kela                	  -2.1	  35.1
Kelah                    	  -2.1	  35.1
La Garrucha              	  -1.8	  37.2
Linosa Island            	  12.9	  35.9
Malaga                   	  -4.4	  36.7
Marsaxlok                	  14.5	  35.8
Marsa Scirocco           	  14.5	  35.8
Marsa Shlok              	  14.5	  35.8
MXloxx                   	  14.5	  35.8
Marabella                	  -4.9	  36.5
Marbella                 	  -4.9	  36.5
Cape Matifu              	   3.2	  36.8
Cap Matifou              	   3.2	  36.8
Cape Mazari              	  -5.2	  35.5
Ras Mazari               	  -5.2	  35.5
Punta de Mazari          	  -5.2	  35.5
Mesa de Roldan           	  -1.9	  36.9
Cortijada La Mesa de Roldan	  -1.9	  36.9
Mellilla Lighthouse      	  -3.0	  35.3
Melilla                  	  -3.0	  35.3
Cape Milonia             	  -2.2	  35.1
Negra Point              	  -5.3	  35.7
Cape Negro               	  -5.3	  35.7
Negro Cape               	  -5.3	  35.7
Negra Point              	  -5.3	  35.7
Nemours                  	  -1.9	  35.1
Palos Cape               	  -0.7	  37.6
Pantellaria Island       	  11.8	  36.8
Pantelleria              	  11.8	  36.8
Pantelaria               	  11.8	  36.8
Penon de Velez de la Gomera	  -4.3	  35.2
Cape Pescadores          	  -4.6	  35.2
Pessadores               	  -4.6	  35.2
Pointe des Pecheurs      	  -4.6	  35.2
Cape Rosa                	   8.2	  36.5
Cap Rosa                 	   8.2	  36.5
Roshgun Lighthouse       	  -1.5	  35.3
Ile Rachgoun             	  -1.5	  35.3
Sabinal Lighthouse Island	  -2.7	  36.7
Cape Sacratif            	  -3.5	  36.7
Cabo Sacritif            	  -3.5	  36.7
Cape St Vincent          	  -6.5	  49.9
Cape San Dimitri         	  14.2	  36.1
Ras San Dimitri          	  14.2	  36.1
Cape Serrat              	   9.2	  37.2
Cap Serrat               	   9.2	  37.2
Cape, Shershel           	   2.2	  36.6
Cape Cherchel            	   2.2	  36.6
Cape Sigli               	   4.8	  36.9
Cap Sigli                	   4.8	  36.9
Sigle                    	   4.8	  36.9
Tabarca                  	  -0.5	  38.2
Illa de Tabarca          	  -0.5	  38.2
Point Targa              	  -4.9	  35.3
Cotella Point            	  -4.9	  35.3
Pointe Tarerha           	  -4.9	  35.3
Punta  Cotelle           	  -4.9	  35.3
Ras el Targa             	  -4.9	  35.3
Tarifa Point             	  -5.6	  36.0
Cape Tenez               	   1.4	  36.6
Cape Tenes               	   1.4	  36.6
Tinosa                   	  -1.1	  37.5
Tinoso                   	  -1.1	  37.5
Torrox Point             	  -4.0	  36.8
Trafalgar                	  -6.0	  36.2
Cape Tres Forcas         	  -3.0	  35.4
Cape des Trois Fourches  	  -3.0	  35.4
Valletta Harbours        	  14.5	  35.9
Villajoyosa              	  -0.2	  38.5
Vila Joiosa              	  -0.2	  38.5
Zafarin Islands         	  -2.4	  35.2
Zafarani                 	  -2.4	  35.2
Djaeferin Islands        	  -2.4	  35.2
Chafarinas Islands       	  -2.4	  35.2
Chanak                   	  26.4	  40.2  # Black Sea / Bosphorous
Canakkale                	  26.4	  40.2
Arablar                   	  27.5	  40.5
Avsaadasi                 	  27.5	  40.5
Batche                   	  29.0	  41.0
Fenerbahce               	  29.0	  41.0
Buyukdere                 	  29.0	  41.2
Fener Adasi              	  28.1	  40.5
Ismid                     	  29.7	  40.7
Khairsiz Ada              	  27.5	  40.6
Marmara                   	  27.6	  40.6
Pasha Liman               	  27.6	  40.5
Pasalimani                	  27.6	  40.5
Polatia Bursa             	  27.5	  40.3
Palatiya                  	  27.5	  40.3
Panderma                  	  28.0	  40.4
Bandirma                  	  28.0	  40.4
Prinkipos                	  29.1	  40.9
Buyukada                 	  29.1	  40.9
Amastra                    	  32.4	  41.8
Amasra                     	  32.4	  41.8
Ieros                   	  39.7	  41.0
Yoros                   	  39.7	  41.0
Unieh                     	  37.3	  41.1
Unye                      	  37.3	  41.1
Yasun                    	  37.7	  41.1
Ince Burnu                	  34.9	  42.1
Sinop                    	  34.9	  42.1
Kerempeh                   	  33.3	  42.0
Vona                      	  37.8	  41.1
Batoum                     	  41.7	  41.7
Batum                      	  41.7	  41.7
Batumi                     	  41.7	  41.7
Kintrist                   	  41.8	  41.8
Kinkisha                   	  41.8	  41.8
Tskhirish                	  41.7	  41.8
Tsikhisdziri             	  41.7	  41.8
Poti                     	  41.7	  42.2
Gagri                      	  40.3	  43.3
Gagra                      	  40.3	  43.3
Pitsvints                 	  40.3	  43.1
Bichvint'a                	  40.3	  43.1
Adler's Point            	  39.9	  43.4
Anapa                      	  37.3	  44.9
Novorossisk                	  37.8	  44.7
Novorosiis'ke              	  37.8	  44.7
Odessa                     	  30.2	  45.3
Serpent                    	  30.2	  45.3
Serpilor                    	  30.2	  45.3
Zmeiny                     	  30.2	  45.3
Sevastopol                 	  33.6	  44.5
Theodosia                 	  35.4	  45.0
Feodosiya                 	  35.4	  45.0
Yalta                       	  34.2	  44.5
Sitka                      	-135.4	  57.0
Upernivik                 	 -52.8	  71.3
San pedro calif            	-118.3	  33.7
St Michael                	-162.0	  63.5
Saint Michael               	-162.0	  63.5
Popof                       	-160.4	  55.3
Pt Belcher                 	-159.7	  70.8
Sausalito                  	-122.3	  37.8
Oakland                   	-122.3	  37.8
Valdez                    	-146.3	  61.1
