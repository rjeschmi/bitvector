package MyWorker;


sub run {
    my ($var1, $var2) = @_;

    sleep($var2);

    return $var1+$var2;
}


1;
