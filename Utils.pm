package Utils;

# a bunch of quick almost one-liners I probably have defined in many places
# and got tired of :)

@EXPORT = qw(
    _logstart _warn _die _log _exit _chdir _open _print slurp
);
use Exporter 'import';

use strict;
use warnings;
use 5.10.0;

my $LOGF;
my $logfh;

sub _logstart {
    $LOGF = shift;
    open( $logfh, ">>", $LOGF ) or die "$! on open '$LOGF'";
    _log("== ARGV ==:", @ARGV);
}

sub _warn {
    _log( 'WARNING', @_ );
    warn @_, "\n";
}

sub _die {
    _log( 'FATAL:', @_ );
    die @_, "\n";
}

sub _log {
    say $logfh gen_ts() . " $$ " . join( " ", @_ );
}

sub _exit {
    my $rc = shift || '(no exit code supplied)';
    _log ( 'EXIT:', $rc);
    exit $rc || 0;
}

sub _chdir {
    chdir( $_[0] || $ENV{HOME} ) or _die "chdir $_[0] failed: $!";
}

sub _open {
    open( my $fh, $_[0], $_[1] ) or _die "open $_[1] failed: $!";
    return $fh;
}

sub _print {
    my ( $file, @text ) = @_;
    my $fh = _open( ">", "$file.$$" );
    print $fh @text;
    close($fh) or _die "close $file failed: $! at ", (caller)[1], " line ", (caller)[2];
    my $oldmode = ( ( stat $file )[2] );
    rename "$file.$$", $file;
    chmod $oldmode, $file if $oldmode;
}

sub slurp {
    return unless defined wantarray;
    local $/ = undef unless wantarray;
    my $fh = _open( "<", $_[0] );
    return <$fh>;
}

# ----------------------------------------------------------------------

sub gen_ts {
    my ( $s, $min, $h, $d, $m, $y ) = (localtime)[ 0 .. 5 ];
    $y += 1900; $m++;    # usual adjustments
    for ( $s, $min, $h, $d, $m ) {
        $_ = "0$_" if $_ < 10;
    }
    my $ts = "$y-$m-$d.$h:$min:$s";

    return $ts;
}

1;
