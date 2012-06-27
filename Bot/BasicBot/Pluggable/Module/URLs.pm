package Bot::BasicBot::Pluggable::Module::URLs;

use Encode;
use LWP::UserAgent;
use WWW::Mechanize;

use base 'Bot::BasicBot::Pluggable::Module';

sub admin {
    my ($self, $args) = @_;
    return;
}

sub told {
    my ($self, $args) = @_;

    printf STDERR "<%s> %s\n", $args->{who}, $args->{body};
    # Let's ignore what we say, shall we?
    if ($args->{who} ne $self->bot()->nick) {
        if ($args->{body} =~ m{spotify:}) {
            $self->parse_spotify($args);
        } elsif ($args->{body} =~ m{((https?://|www\.)youtube\.com)}) {
            $self->parse_youtube($args);
        } else {
            $self->parse_urls($args);
        }
    }

    return;
}

sub fallback {
    my ($self, $args) = @_;
    return;
}

sub parse_spotify {
    my ($self, $args) = @_;

    my (@spotify) = $args->{body} =~ m{(spotify:\S+)}gmxis;
    my $num_songs = 1;
    for (@spotify) {
        $_ =~ s/:/\//g;
        $_ =~ s/spotify/http:\/\/open.spotify.com/;

        my $title = $self->get_title($_);
        if ($title) {
            $self->bot()->say(
                channel => $args->{channel},
                body => (sprintf "[%d] %s <%s>", $num_songs++, $title, $_),
            );
        }
    }
}

sub parse_youtube {
    my ($self, $args) = @_;
    my (@urls) = $args->{body} =~ m{((https?://|www.)youtube\S+)}gmxis;
    my $num_urls = 1;
    my $mech = WWW::Mechanize->new(onerror => \&err, agent => 'Opera/9.80 (X11; Linux x86_64; U; en-GB) Presto/2.10.289 Version/12.00');
    for my $url (@urls) {
        $url = 'http://' . $url if $url !~ /^http/;
        next unless $url =~ m{^https?://(www\.)?\S+};

        $mech->get($url);
        my $title = $self->get_title($url);

        my ($view_count) = $mech->content() =~ m{<span\s+class="watch-view-count">\s+<strong>(.*?)</strong>}xmis;
        my ($likes, $dislikes) = $mech->content() =~ m{<span\sclass="watch-likes-dislikes">\s+<span\s+class="likes">(.*?)</span>\s+likes,\s+<span\s+class="dislikes">(.*?)</span>\s+dislikes}xmis;
        $title =~ s/\s-\sYouTube$//;
        if ($title) {
            $self->bot()->say(
                channel => $args->{channel},
                body => (sprintf "[%d] %s (%s views, +%s/-%s)", $num_urls++, $title, $view_count, $likes, $dislikes),
            );
        }
    }
}

sub parse_urls {
    my ($self, $args) = @_;
    my (@urls) = $args->{body} =~ m{^((https?://|www\.)\S+)}gmxis;
    my $num_urls = 1;
    for my $url (@urls) {
        $url = 'http://' . $url if $url !~ /^http/;
        next unless $url =~ m{^https?://(www\.)?\S+};

        # Remove JavaScript hashbangs.
        $url =~ s/\/#!\//\//g;

        my $title = $self->get_title($url);
        if ($title) {
            $self->bot()->say(
                channel => $args->{channel},
                body => (sprintf "[%d] %s", $num_urls++, $title),
            );
        }
    }
}

sub get_title {
    my ($self, $url) = @_;

    my $mech = WWW::Mechanize->new(onerror => \&err, agent => 'Opera/9.80 (X11; Linux x86_64; U; en-GB) Presto/2.10.289 Version/12.00');

    $mech->get($url);

    my $title = $mech->title;

    if (!$title) {
        my $ua = LWP::UserAgent->new;
        my $response = $ua->get($url);


        ($title) = $response->content =~ m{<title>(.*?)</title>}xmsi;
        Encode::_utf8_on($title);
    }

    return $title;
}

1;
