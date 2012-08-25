#!/usr/bin/env perl
use strict;
use warnings;

use POSIX;
use Bot::BasicBot::Pluggable;
use Getopt::Long;

GetOptions(
    'nick:s'     => \my $nick,
    'server:s'   => \my $server,
    'port:s'     => \my $port,
    'channels:s'  => \my $channels,
);

$server     //= q();    # Default server
$port       //= "6667"; # Default port
$channels   //= q();   # Default channels to join
$nick       //= "Pwner";    # The bot's nick

die 'Usage ./pwner.pl --nick <nickname> --server <servername> --port <port number> --channels "<#channel1,#channel2>"' unless $server && $port && $channels && $nick;

my $pid = fork();
exit if $pid;
POSIX::setsid();

my $bot = Bot::BasicBot::Pluggable->new(
    server      => $server,
    port        => $port,
    channels    => [ split ',', $channels ],
    nick        => $nick,
    username    => lc $nick,
    charset     => "utf-8",
);

$bot->load('Loader');
$bot->load('Auth');
$bot->load('URLs');

$bot->run();
