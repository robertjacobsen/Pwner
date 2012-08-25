package PwnBot;

use Data::Dumper;

use base qw(Bot::BasicBot::Pluggable);

sub connected {
    my ($self, $args) = @_;
}

sub said {
    my ($self, $args) = @_;

    #printf STDERR "<%s> %s\n", $args->{who}, $args->{body};
}

sub err {
    warn join '', @_;
}

1;
