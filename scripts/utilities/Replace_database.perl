#!/opt/local/bin/perl

# Delete the existing oldWeather3 operational database and install another from backup files.

use strict;
use warnings;
use FindBin;
use Getopt::Long;
use MongoDB;
use MongoDB::OID;
use boolean;

my $Backup_dir;
GetOptions( "dir=s" => \$Backup_dir);
unless(defined($Backup_dir) && -d $Backup_dir) {
	die "No directory supplied";
}

# Drop the existing database
my $conn = MongoDB::MongoClient->new( query_timeout => -1 ) or die "No database connection";
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 production database not found";
my $Removed = $db->drop;

# Reload from backup
system("mongorestore \"$Backup_dir\"");

# Add indexes linking Annotations to transcriptions
#  and transcriptions to assets.
$conn = MongoDB::MongoClient->new( query_timeout => -1 ) or die "No database connection";
$db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 production database not found";
$db->get_collection( 'annotations' )->ensure_index({'transcription_id' => 1});
$db->get_collection( 'transcriptions' )->ensure_index({'asset_id' => 1});
