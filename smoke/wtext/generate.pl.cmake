#!/usr/bin/perl -w

## Run this first, to generate the x_*.cpp files from the Qt headers
## using kalyptus

my $kalyptusdir = "@CMAKE_CURRENT_SOURCE_DIR@/../../kalyptus";

use File::Basename;
use File::Copy qw|cp|;
use File::Compare;
use File::Find;
use Cwd;

my $here = getcwd;
my $outdir = $here . "/generate.pl.tmpdir";
my $finaloutdir = $here;
my $defines = "qtdefines";
my $definespath = "$here/../$defines";
my $wt_headerlist = "";
my $wt_headerlistpath = "";
my $wtext_headerlist = "";
my $wtext_headerlistpath = "";

$wt_headerlist = "@CMAKE_CURRENT_SOURCE_DIR@/wt_header_list";
$wt_headerlistpath = "$here/$wt_headerlist";

$wtext_headerlist = "@CMAKE_CURRENT_SOURCE_DIR@/wtext_header_list";
$wtext_headerlistpath = "$here/$wtext_headerlist";

$boost_headerlist = "@CMAKE_CURRENT_SOURCE_DIR@/boost_header_list";
$boost_headerlistpath = "$here/$boost_headerlist";

## If srcdir != builddir, use headerlist from src
$wt_headerlistpath = $wt_headerlist if ($wt_headerlist =~ /^\//);
$wtext_headerlistpath = $wtext_headerlist if ($wtext_headerlist =~ /^\//);
$boost_headerlistpath = $boost_headerlist if ($boost_headerlist =~ /^\//);

## Note: outdir and finaloutdir should NOT be the same dir!

# Delete all x_*.cpp files under outdir (or create outdir if nonexistent)
if (-d $outdir) { system "rm -f $outdir/x_*.cpp"; } else { mkdir $outdir; }

mkdir $finaloutdir unless (-d $finaloutdir);

#  Load the QT_NO_* macros found in "qtdefines". They'll be passed to kalyptus
my $macros="";
if ( -e $definespath ){
    print "Found '$defines'. Reading preprocessor symbols from there...\n";
    $macros = " --defines=$definespath ";
}

mkdir $kalyptusdir, 0777;
# Need to cd to kalyptus's directory so that perl finds Ast.pm etc.
chdir "$kalyptusdir" or die "Couldn't go to $kalyptusdir (edit script to change dir)\n";


# Some systems have a QTDIR = KDEDIR = PREFIX
# We need a complete list

my $wtincludes;
open(HEADERS, $wt_headerlistpath) or die "Couldn't open $wt_headerlistpath: $!\n";
map { chomp ; $wtincludes{$_} = 1 } <HEADERS>;
close HEADERS;

open(HEADERS, $wtext_headerlistpath) or die "Couldn't open $wtext_headerlistpath: $!\n";
map { chomp ; $wtincludes{$_} = 1 } <HEADERS>;
close HEADERS;

my @wtheaders = ();
$kdeprefix = "@KDE_PREFIX@";
$wtinc = '@Wt_INCLUDE_DIR@';
$wtinc =~ s/\${prefix}/$kdeprefix/; # Remove ${prefix} in src != build
-d $wtinc or die "Couldn't process $wtinc: $!\n";

find(
    {   wanted => sub {
	    (-e || -l and !-d) and do {
	        $f = substr($_, 1 + length $wtinc);
                push ( @wtheaders, $_ ) if ($wtincludes{$f});
	    	undef $wtincludes{$f}   
	     };
	},
	follow_fast => 1,
	follow_skip => 2,
	no_chdir => 1
    }, $wtinc
 );

my $boostincludes;
open(HEADERS, $boost_headerlistpath) or die "Couldn't open $boost_headerlistpath: $!\n";
map { chomp ; $boostincludes{$_} = 1 } <HEADERS>;
close HEADERS;

my $boostinc = "@Boost_INCLUDE_DIR@";
$boostinc =~ s/\${prefix}/$kdeprefix/; # Remove ${prefix} in src != build
-d $boostinc or die "Couldn't process $boostinc: $!\n";

find(
    {   wanted => sub {
	    (-e || -l and !-d) and do {
	        $f = substr($_, 1 + length $boostinc);
                push ( @wtheaders, $_ ) if ($boostincludes{$f});
	    	undef $boostincludes{$f}   
	     };
	},
	follow_fast => 1,
	follow_skip => 2,
	no_chdir => 1
    }, $boostinc
 );

push ( @wtheaders, "@CMAKE_CURRENT_SOURCE_DIR@/dummy/string" );
push ( @wtheaders, "@CMAKE_CURRENT_SOURCE_DIR@/dummy/any.hpp" );
push ( @wtheaders, "@CMAKE_CURRENT_SOURCE_DIR@/dummy/regex.hpp" );

# Launch kalyptus
chdir "../smoke/wt";
system "perl -I@kdebindings_SOURCE_DIR@/kalyptus @kdebindings_SOURCE_DIR@/kalyptus/kalyptus @ARGV --qt4 --globspace -fsmoke --name=wtext --classlist='@CMAKE_CURRENT_SOURCE_DIR@/classlist' --init-modules=wt $macros --no-cache --outputdir=$outdir @wtheaders";
my $exit = $? >> 8;
exit $exit if ($exit);
chdir "$kalyptusdir";

# Generate diff for smokedata.cpp
unless ( -e "$finaloutdir/smokedata.cpp" ) {
    open( TOUCH, ">$finaloutdir/smokedata.cpp");
    close TOUCH;
}
system "diff -u $finaloutdir/smokedata.cpp $outdir/smokedata.cpp > $outdir/smokedata.cpp.diff";

# Copy changed or new files to finaloutdir
opendir (OUT, $outdir) or die "Couldn't opendir $outdir";
foreach $filename (readdir(OUT)) {
    next if ( -d "$outdir/$filename" ); # only files, not dirs
    my $docopy = 1;
    if ( -f "$finaloutdir/$filename" ) {
        $docopy = compare("$outdir/$filename", "$finaloutdir/$filename"); # 1 if files are differents
    }
    if ($docopy) {
	#print STDERR "Updating $filename...\n";
	cp("$outdir/$filename", "$finaloutdir/$filename");
    }
}
closedir OUT;

# Check for deleted files and warn
my $deleted = 0;
opendir(FINALOUT, $finaloutdir) or die "Couldn't opendir $finaloutdir";
foreach $filename (readdir(FINALOUT)) {
    next if ( -d "$finaloutdir/$filename" ); # only files, not dirs
    if ( $filename =~ /.cpp$/ && ! ($filename =~ /_la_closure.cpp/) && ! -f "$outdir/$filename" ) {
      print STDERR "Removing obsolete file $filename\n";
      unlink "$finaloutdir/$filename";
      $deleted = 1;
    }
}
closedir FINALOUT;

# Delete outdir
system "rm -rf $outdir";

