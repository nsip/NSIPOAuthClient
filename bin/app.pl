#!/usr/bin/env perl
use Dancer;
use Net::OAuth2::Client;
use URI;

set port => 3002;

if (!defined($ARGV[0])) {
    print STDERR "Usage: app.pl URI-of-oauth-server\n";
    exit 1;
}

sub client {
  Net::OAuth2::Client->new(
      'nsip-oauth-perl',
      '123456789',
      site => $ARGV[0],
      access_token_url => '/oauth/token'
  )->web_server(
    redirect_uri => uri_for('/auth/callback')
  );
}

# Send user to authorize with service provider
get '/auth' => sub {
  redirect client->authorize;
};

# User has returned with '?code=foo' appended to the URL.
get '/auth/callback' => sub {

  # Use the auth code to fetch the access token
  my $access_token =  client->get_access_token(params->{code});

  # Use the access token to fetch a protected resource
  my $response = $access_token->get('/me');

  # Do something with said resource...

  if ($response->is_success) {
    return "Yay, it worked: " . $response->decoded_content;
  }
  else {
    return "Error: " . $response->status_line;
  }
};

dance;
