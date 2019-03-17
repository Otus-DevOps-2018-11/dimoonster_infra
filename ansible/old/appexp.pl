#!/usr/bin/env perl

local $SIG{__WARN__} = sub { };

use warnings;
no warnings;
no warnings "all";

use strict;
use Data::Dumper;
use JSON;

die ("useage $0 [--list|--host <hostname>]\n") unless scalar @ARGV > 0;

## сходим в каталог с terraform и спросим ip адреса
my $dir = `cwd`;
chdir '../terraform/stage';

## спросим у terraform ip адрес хоста app
my $APP_IP = `terraform output app_external_ip`;
## спросим у terraform ip адреса хоста db
my $DB_IP = `terraform output db_external_ip`;
my $DB_IP_INT = `terraform output db_internal_ip`;

chdir $dir;

## Базовая структура
my %struct;
$struct{app} = {
    hosts => [],
    vars => {}
};
$struct{db} = {
    hosts => [],
    vars => {}
};
$struct{_meta} = {
    hostvars => {}
};

## добавим хост app.host в группу app
add_ansible_host('app', 'app.host', $APP_IP);
## добавим хост mongodb.host в группу db
add_ansible_host('db', 'mongodb.host', $DB_IP);

print display() if $ARGV[0] =~ /--list/i;
print display($ARGV[1]) if $ARGV[0] =~ /--host/i;

## Функция возвращает либо сводный json, либо переменные для host
sub display {
    my ($host) = @_;

    ## хост не передан, вернём полные данные
    return encode_json \%struct unless $host;

    ## получим спецыфичные для хоста перменные
    my %host_vars = %{$struct{_meta}{hostvars}{$host}} if $struct{_meta}{hostvars}{$host};

    ## найдём в какую группу входит наш хост и добавим в результирующий хэш переменные группы хостов
    foreach my $hostGroup (keys %struct) {
        next if $hostGroup eq '_meta';
        next if ref $struct{$hostGroup} !~ /hash/i;

        my %groupHostsHash = map { $_ => 1} @{$struct{$hostGroup}{hosts}};
        next if !$groupHostsHash{$host} && !$struct{$hostGroup}{children};

        %host_vars = (%host_vars, %{$struct{$hostGroup}{vars}});
    }

    return encode_json \%host_vars;
}

## Добавление хоста в группу хостов
sub add_ansible_host {
    my ($type, $hostname, $ip) = @_;

    $ip =~ s/^[\s]+|[\s\r\n]+$//g;

    return unless $struct{$type};

    push @{$struct{$type}{hosts}}, $hostname;
    $struct{_meta}{hostvars}{$hostname}{ansible_host} = $ip;
}
