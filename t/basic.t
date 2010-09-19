{

package Test;

use Moose;

use DateTime;
use DateTime::Duration;
use MooseX::Traits::Attribute::Expirable;

#TODO: test with builder
#TODO: test with laziness
#TODO: test to make sure it requires at least a default
#TODO: test with at least two attributes
#TODO: test clear
#TODO: test predicate
#TODO: test named writer
#TODO: test named reader

has did_something_recently => ( 
                                traits => [qw(Expirable)], 
                                is     => 'rw', 
                                isa => 'Bool',
                                default => 0,
                                predicate => 'has_did_something_recently',
                                expires_in => 5,
                                handles => {
                                            expire_did_something_recently => 'expire',
                                           }
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

ok($t->do_something, 'did something!');

is ($t->did_something_recently, 1, 'did something recently immediately');

is ($t->has_did_something_recently, 1, 'has did something recently immediately');

sleep 4;

is ($t->did_something_recently, 1, 'did something recently some 4 seconds later');
is ($t->has_did_something_recently, 1, 'has did something some 4 seconds later');

sleep 2;

is ($t->did_something_recently, 0, 'did something recently some 6 seconds later');
is ($t->has_did_something_recently, 0, 'has did something some 6 seconds later');

ok($t->do_something(), 'did something again!');

is ($t->did_something_recently, 1, 'did something recently after doing something again');

$t->expire_did_something_recently;

is ($t->did_something_recently, 0, 'did something recently after expire via helper');

done_testing;
