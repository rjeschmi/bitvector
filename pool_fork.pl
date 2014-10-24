#!/usr/bin/env perl


use AnyEvent;
use AnyEvent::Fork::Pool;
use lib './lib';

my $pool = AnyEvent::Fork
    ->new
    ->require("MyWorker")
    ->AnyEvent::Fork::Pool::run (
        "MyWorker::run", 
        on_destroy => (my $finish = AE::cv),
        max => 4);


for (1..100) {
    $pool->( ($_,$_+1), sub {
        my ($return) = @_;
        print $return."\n";
    });
}


undef $pool;

$finish->recv;
