# Representation of and oW3 asset (page record)

package Asset;
use Carp;
use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use JSON -convert_blessed_universally;
use Places qw(EstimateLLfromName);
use String::Approx 'amatch';
use Exporter;

#use Data::Dumper;
@Asset::ISA    = qw(Exporter);
@Asset::EXPORT = qw(asset_read);

sub new {
    my $that   = shift;
    my $class  = ref($that) || $that;
    my $id     = shift;
    my $db     = shift;
    my $assetI = $db->get_collection('assets')->find( { "_id" => $id } );
    my $self   = $assetI->next;                        # Assume there's only one
    bless $self, $class;
    return $self;
}

sub asset_read {
    my $id   = shift;
    my $db   = shift;
    my $Only = shift;                   # If set, use only this transcription
    my $Self = new Asset( $id, $db );
    $Self->read_transcriptions( $db, $Only );

    # Make a cannonical date
    my %Date;
    foreach my $Transcription ( @{ $Self->{transcriptions} } ) {
        foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
            unless ( defined( $Annotation->{data}->{date} ) ) { next; }
            push @{ $Date{date} }, $Annotation->{data}->{date};
        }
    }
    for my $Variable ( keys(%Date) ) {
        (
            $Self->{CDate}->{data}->{$Variable},
            $Self->{CDate}->{qc}->{$Variable}
        ) = Merge_annotations( @{ $Date{$Variable} } );
    }

    # Make a cannonical location
    my %Positions;
    foreach my $Transcription ( @{ $Self->{transcriptions} } ) {
        foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
            unless ( defined( $Annotation->{data}->{latitude} ) ) { next; }
            if ( defined( $Annotation->{data}->{port} )
                && $Annotation->{data}->{port} =~ /\w+/ )
            {
                my $LL = (
                    EstimateLLfromName(
                        $Annotation->{data}->{port},
                        0, 90, 0, 180
                    )
                )[0];
                $Annotation->{data}->{portname} = $LL->[0];
                $Annotation->{data}->{portlon}  = $LL->[1];
                $Annotation->{data}->{portlat}  = $LL->[2];
            }

            for my $Variable ( keys( %{ $Annotation->{data} } ) ) {
                unless ( defined( $Annotation->{data}->{$Variable} )
                    && $Annotation->{data}->{$Variable} =~ /\w/ )
                {
                    next;
                }
                push @{ $Positions{$Variable} },
                  $Annotation->{data}->{$Variable};
            }
        }
    }
    for my $Variable ( keys(%Positions) ) {
        (
            $Self->{CPosition}->{data}->{$Variable},
            $Self->{CPosition}->{qc}->{$Variable}
        ) = Merge_annotations( @{ $Positions{$Variable} } );
    }
    my @CWeather;
    for ( my $Hour = 1 ; $Hour <= 24 ; $Hour++ ) {
        my %Hourly;
        foreach my $Transcription ( @{ $Self->{transcriptions} } ) {
            foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
                if (   defined( $Annotation->{data}->{Chour} )
                    && length( $Annotation->{data}->{Chour} ) > 0
                    && $Annotation->{data}->{Chour} == $Hour )
                {
                    for my $Variable ( keys( %{ $Annotation->{data} } ) ) {
                        if ( $Variable =~ /hour/ ) { next; }
                        push @{ $Hourly{$Variable} },
                          $Annotation->{data}->{$Variable};
                    }
                }
            }
        }
        for my $Variable ( keys(%Hourly) ) {
            (
                $Self->{CWeather}[$Hour]->{data}->{$Variable},
                $Self->{CWeather}[$Hour]->{qc}->{$Variable}
            ) = Merge_annotations( @{ $Hourly{$Variable} } );
        }
    }

    return ($Self);
}

sub read_transcriptions {
    my $Asset = shift;
    my $db    = shift;
    my $Only  = shift;
    $Asset->{transcriptions} = ();
    my $transcriptionI =
      $db->get_collection('transcriptions')->find( { "asset_id" => $Asset->{_id} } );
    my $Count = 0;
    while ( my $Transcription = $transcriptionI->next ) {

        # Get all the annotations comprising this transcription
        if ( defined($Only) && ++$Count == $Only ) { next; }
        $Transcription->{annotations} = ();
        my $annotationI = $db->et_collection('annotations')->find(
            { "transcription_id" => $Transcription->{_id} } );
        unless ( defined($annotationI) ) {
            warn "No annotations for $Transcription->{_id}";
            next;
        }
        my @Annotations;

        while ( my $Annotation = $annotationI->next ) {
            push @Annotations, $Annotation;
        }

        # Sort by position on the page (top to bottom)
        @Annotations =
          sort { $a->{bounds}->{y} <=> $b->{bounds}->{y} } @Annotations;

        my $MaxH = 0;
        for ( my $i = 0 ; $i < scalar(@Annotations) ; $i++ ) {

            if ( defined( $Annotations[$i]->{data}->{air_temperature} ) ) {

                # Clean up the inputs
                for my $Variable ( keys( %{ $Annotations[$i]->{data} } ) ) {
                    if ( $Variable =~ /hour/ ) { next; }
                    my $Last;
                    if ( $i > 0 ) {
                        $Last = $Annotations[ $i - 1 ]->{data}->{$Variable};
                    }
                    $Annotations[$i]->{data}->{$Variable} =
                      CS_weather( $Annotations[$i]->{data}->{$Variable},
                        $Last, $Variable );
                }

                # Add a cannonical hour
                my $Chour = Make_cannonical_hour( $Annotations[$i], $MaxH );
                if (   defined($Chour)
                    && $Chour =~ /\d/
                    && $Chour !~ /\D/
                    && $Chour > $MaxH )
                {
                    $MaxH = $Chour;
                }
                $Annotations[$i]->{data}->{Chour} = $Chour;

            }

            if ( defined( $Annotations[$i]->{data}->{latitude} ) ) {
                $Annotations[$i]->{data}->{latitude} =
                  CS_latitude( $Annotations[$i]->{data}->{latitude} );
            }
            if ( defined( $Annotations[$i]->{data}->{longitude} ) ) {
                $Annotations[$i]->{data}->{longitude} =
                  CS_longitude( $Annotations[$i]->{data}->{longitude} );
            }
            if ( defined( $Annotations[$i]->{data}->{port} ) ) {
                $Annotations[$i]->{data}->{port} =
                  CS_port( $Annotations[$i]->{data}->{port} );

            }
        }

        push @{ $Transcription->{annotations} }, @Annotations;

        push @{ $Asset->{transcriptions} }, $Transcription;
    }
}

# Clean and standardise a weather variable
sub CS_weather {
    my $Var   = shift;
    my $Last  = shift;    # cleaned previous observation
    my $Which = shift;
    if ( defined($Last) && $Var =~ /\"|do/ ) { $Var = $Last; }    # Dittos
    if ( $Which eq 'air_temperature' ) {
        if ( defined($Last) && $Var =~ /\"|do/ ) { $Var = $Last; }
        $Var =~ s/[^\.\-\d]//g;
        return $Var;
    }
    if ( $Which eq 'bulb_temperature' ) {
        $Var =~ s/[^\.\-\d]//g;
        return $Var;
    }
    if ( $Which eq 'clear_sky' ) {
        $Var =~ s/\D//g;
        return $Var;
    }
    if ( $Which eq 'height_1' ) {
        $Var =~ s/[^\.\d]//g;
        if ( $Var =~ /^\./ && defined($Last) && $Last =~ /(\d\d)\./ ) {
            $Var = $1 . $Var;
        }
        return $Var;
    }
    if ( $Which eq 'height_2' ) {
        $Var =~ s/[^\-\d]//g;
        return $Var;
    }
    if ( $Which eq 'sea_temperature' ) {
        $Var =~ s/\.\D//g;
        return $Var;
    }
    if ( $Which eq 'weather_code' ) {
        $Var = lc($Var);
        $Var =~ s/[^a-z]//g;
        return $Var;
    }
    if ( $Which eq 'wind_direction' ) {
        $Var = lc($Var);
        $Var =~ s/[^a-z1-4\/]//g;
        $Var =~ s/by/x/;
        return $Var;
    }
    if ( $Which eq 'wind_force' ) {
        $Var =~ s/[^\.\-\d]//g;
        return $Var;
    }
    if ( $Which eq 'cloud_code' ) {
        $Var = lc($Var);
        return $Var;
    }
    die "Unknown weather variable $Which";
}

sub Make_cannonical_hour {
    my $Annotation = shift;
    my $MaxH       = shift;
    my $Chour      = $Annotation->{data}->{hour};
    if ( $Chour =~ /-|to/ ) { return ''; }
    $Chour =~ s/[\.:\s]+//g;
    if     ( lc($Chour) =~ /0*(\d+)pm/ ) { return $1 + 12; }
    if     ( lc($Chour) =~ /0*(\d+)am/ ) { return $1; }
    if     ( lc($Chour) =~ /0*(\d+)00/ ) { return $1; }
    if     ( lc($Chour) =~ /^0(\d)$/ )   { return $1; }
    if     ( lc($Chour) =~ /noon/ )      { return 12; }
    if     ( lc($Chour) =~ /mid/ )       { return 24; }
    unless ( $Chour     =~ /(\d+)/ )     { return; }
    if     ( $Chour     =~ /\D/ )        { return; }
    $Chour = $1;

    if ( $Chour > 12 ) {
        return $Chour;
    }
    if ( $Chour < $MaxH && $Chour <= 12 ) { $Chour += 12; }    # Must be pm
    return $Chour;
}

sub Merge_annotations {
    my @Raw;
    foreach (@_) {
        if ( $_ =~ /\S/ ) { push @Raw, $_; }
    }
    if ( scalar(@Raw) == 0 ) { return ( "",    "0" ); }
    if ( scalar(@Raw) == 1 ) { return ( $_[0], "1" ); }
    my %Items;
    foreach my $Item (@Raw) {
        my @Matched = amatch( $Item, @Raw );
        foreach my $MItem (@Matched) { $Items{$MItem}++; }
    }
    if ( scalar( keys(%Items) ) == 1 ) { return ( $_[0], "U" ); }
    my @Values = sort { $Items{$b} <=> $Items{$a} } ( keys(%Items) );
    if ( $Items{ $Values[0] } > $Items{ $Values[1] } ) {
        return ( "$Values[0]", "M" );
    }
    if ( $Items{ $Values[0] } >= 2 ) {
        return ( "$Values[0]", "D" );
    }
    return ( "$Values[0]", "X" );
}

# Clean and standardise a latitude
sub CS_latitude {
    my $Latitude  = shift;
    my $Has_north = 0;
    my $Has_south = 0;
    my ( $Degrees, $Minutes );
    my $Result;
    if ( $Latitude =~ /[nN]/ ) { $Has_north = 1; }
    if ( $Latitude =~ /[sS]/ ) { $Has_south = 1; }
    if ( $Latitude =~ /^\D*(\d+)/ ) {
        $Degrees = $1;
        if ( $Latitude =~ /^\D*\d+\D+(\d+)/ ) { $Minutes = $1; }
    }
    if ( defined($Degrees) ) {
        $Result = sprintf "%02d", $Degrees;
        if ( defined($Minutes) ) { $Result .= sprintf " %02d", $Minutes; }
        if ( $Has_north == 1 && $Has_south == 0 ) { $Result .= " N"; }
        if ( $Has_south == 1 && $Has_north == 0 ) { $Result .= " S"; }
        return $Result;
    }
    return $Latitude;
}

# Clean and standardise a longitude
sub CS_longitude {
    my $Longitude = shift;
    my $Has_east  = 0;
    my $Has_west  = 0;
    my ( $Degrees, $Minutes );
    my $Result;
    if ( $Longitude =~ /[eE]/ ) { $Has_east = 1; }
    if ( $Longitude =~ /[wW]/ ) { $Has_west = 1; }
    if ( $Longitude =~ /^\D*(\d+)/ ) {
        $Degrees = $1;
        if ( $Longitude =~ /^\D*\d+\D+(\d+)/ ) { $Minutes = $1; }
    }
    if ( defined($Degrees) ) {
        $Result = sprintf "%02d", $Degrees;
        if ( defined($Minutes) ) { $Result .= sprintf " %02d", $Minutes; }
        if ( $Has_east == 1 && $Has_west == 0 ) { $Result .= " E"; }
        if ( $Has_west == 1 && $Has_east == 0 ) { $Result .= " W"; }
        return $Result;
    }
    return $Longitude;
}

# Clean and standardise a port name
sub CS_port {
    my $Port = shift;
    $Port = lc($Port);
    $Port =~ s/\s+/ /g;
    $Port =~ s/^\s+//;
    $Port =~ s/\s+$//;
    $Port =~ s/[^\w ]//g;
    return ($Port);
}

# Convert to a JSON text string (for passing to R)
sub to_JSON {
    my $Self = shift;
    my $json = JSON->new;

    #$json = $json->utf8;
    $json = $json->allow_blessed(true);
    $json = $json->convert_blessed(true);
    $json = $json->pretty(true);
    my $jTxt = $json->encode($Self);
    return ($jTxt);
}
