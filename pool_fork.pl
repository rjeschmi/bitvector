#!/usr/bin/env perl


use AnyEvent;
use AnyEvent::Fork::Pool;
use Data::Printer;
use lib './lib';

my $pool = AnyEvent::Fork
    ->new
    ->require("MyWorker")
    ->AnyEvent::Fork::Pool::run (
        "MyWorker::run", 
        on_destroy => (my $finish = AE::cv),
        max => 4);

my $global = {};

for my $input (1..100) {
    $pool->( ($input,$input+1), sub {
        my ($return) = @_;
        $global->{$input}=$return."\n";
        p $global;
    });
}


undef $pool;

$finish->recv;
