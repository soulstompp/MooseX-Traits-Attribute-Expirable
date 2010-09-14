{

package Test;

use Moose;

use DateTime;
use DateTime::Duration;
use MooseX::Traits::Attribute::Expirable;

my $recently = DateTime::Duration->new(
                                       seconds => 5,  
                                      );

has did_something_recently => ( 
                                traits => [qw(Expirable)], 
                                is     => 'rw', 
                                isa => 'Bool',
                                default => 0,
                                expires_in => $recently,
                              );

sub _build_did_something_recently {
    my $self = shift;

    return 0;
}

sub do_something {
    my ($self) = @_;

    $self->did_something_recently(1);

    return 1;
}

}

package main;

use Test::More;

my $t = Test->new();

ok($t->do_something(), 'did something!');

is ($t->did_something_recently, 1, 'did something recently immediately');

sleep 4;

is ($t->did_something_recently, 1, 'did something recently some 4 seconds later');

sleep 2;

is ($t->did_something_recently, 0, 'did something recently some 6 seconds later');

ok($t->do_something(), 'did something again!');

is ($t->did_something_recently, 1, 'did something recently after doing something again');


done_testing;
