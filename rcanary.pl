#!/usr/bin/perl -w

use strict;
use warnings;
use Config;
use Carp;
use Data::Dumper;

# a_type AT_RANDOM == 25 (https://github.com/lattera/glibc/blob/master/elf/elf.h#L947)
use constant AT_RANDOM => 25;
my %arch;
BEGIN {
    if ($Config{archname} =~ /^x86_64/) {
        %arch = (
            len => 8,
            pack => "Q"
        );
    }else {
        %arch = (
            len => 4,
            pack => "I"
        );
    }
};


sub get_at_random_address($\$) {
    my $pid = shift;
    my $dst = shift;
    carp "PID supplied is not a number or empty" and return if ($pid !~ /^[0-9]+$/);

    open(P, "</proc/$pid/auxv") || ( warn "[-] Couldn't read auxv file for pid $pid." and return undef );
    
    my($r, $r_t);
    my($a_type, $at_random);
    while($r = read(P, $r_t, $arch{len})) {
        my $a_type = unpack('Q', $r_t);
        if ($a_type == AT_RANDOM) {
            read(P, $r_t, $arch{len});
            goto error if (!defined $r_t);
            $at_random = unpack($arch{pack}, $r_t);
            goto end;
        }
    }
error:
    warn "[-] Error read()'ing auxv. Aborting pid $pid..." and return undef if (!defined $r);
end:
    close(P);
    if (!defined $at_random) {
        warn "[?] AT_RANDOM not found. This binary was compiled with SSP?" if $ENV{DEBUG};
        return undef;
    }
    printf "[+] AT_RANDOM for pid $pid: %x\n", $at_random;
    $$dst = $at_random;
}

sub read_memory($$) {
    my $pid = shift;
    my $addr = shift;
    carp "PID or ADDR not defined" and return if (!defined $pid or !defined $addr);

    open(M, "</proc/$pid/mem") || ( warn "[-] Couldn't read mem file for pid $pid." and return undef );
    my $r_t;
    my $canary;

    seek(M, $addr, 0);
    read(M, $r_t, $arch{len});
    $canary = unpack($arch{pack}, $r_t);

    printf("[+] Canary for pid $pid: %x\n", $canary);

    close(M);
}

sub get_canary($) {
    my $pid = shift;
    warn "[-] No auxiliar information for pid $pid. Next." and next if (!-r "/proc/$pid/auxv");
    
    my $addr;
    return if !get_at_random_address($pid, $addr);

    my $canary = undef;
    read_memory($pid, $addr);
}

if ($#ARGV >= 0) {
    print STDERR <<EOH and exit(1) if ( $ARGV[0] eq "-h" or $ARGV[0] eq "-h" );
./$0 (pid)
    (pid) is optional
EOH
    get_canary($ARGV[0]);
}else{

    opendir(FD,"/proc") or die($!);
    my @pids = grep { !/^1$/ && /^[0-9]+$/ } readdir(FD);
    closedir(FD);

    foreach my $p(@pids) {
        next if ($$ eq $p);
        get_canary($p);
    }
}

exit 0;
