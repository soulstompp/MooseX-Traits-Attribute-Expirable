package MooseX::Traits::Attribute::Expirable;

use Moose::Role;

our $VERSION   = '0.01';

$VERSION = eval $VERSION;

our $AUTHORITY = 'cpan:soulstompp';

#TODO: do we need to consider timezones if this is going to be used on multiple machines (think KiokuDB)?
with 'Moose::Meta::Attribute::Native::Trait';

use Moose::Meta::Attribute::Custom::MethodProvider::Expirable;
#TODO: make this an install dependency
use MooseX::Types::DateTime;
#TODO: we are going to probably need a DateTime::Set Type as well or those coercions are going to suck.

has 'method_provider' => (
                          is => 'ro',
                          isa       => 'ClassName',
                          predicate => 'has_method_provider',
                          default   => 'Moose::Meta::Attribute::Custom::MethodProvider::Expirable',
                         );

sub _default_is { 'ro' }
sub _helper_type { 'Any' }

has _expiration_date => (
                         is => 'rw',
                         isa => 'Maybe[DateTime]',
                         required => 0,
                         clearer   => '_clear__expiration_date',
                         predicate => 'has__expiration_date',
                        );

#TODO: check to make sure expires_in and expires_at aren't set at the same time
#TODO: this needs a decent default.... probably a duration of 0 seconds
has expires_in => (
                   is        => 'rw',
                   isa       => 'DateTime::Duration',
                   predicate => 'has_expires_in',
                   clearer   => 'clear_expires_in',
                   required  => 0,
                   coerce    => 1,
                 );

has expires_at => (
                   is        => 'rw',
                   isa       => 'DateTime',
                   required  => 0,
                   predicate => 'has_expires_at',
                   clearer   => 'clear_expires_at',
                   coerce    => 1,
                  );

after install_accessors => sub {  
    my ($attr, $inline) = @_;

    #TODO: make sure that we play nicely with inline methods.

    my $attr_name = $attr->name;
    my $attr_class = $attr->associated_class;
    my $attr_meta = $attr->meta;

    if ($attr->get_read_method() eq $attr->get_write_method()) {
        $attr_class->add_around_method_modifier($attr->accessor, sub {
                                                                      my $orig = shift;
                                                                      my $self = shift;

                                                                      my @args = @_;

                                                                      if (scalar @args) {
                                                                          $attr->_reset__expiration_date();
                                                                              
                                                                          return $self->$orig(@_);
                                                                      }
                                                                      else {
                                                                          return $attr->_get_fresh_value($self);
                                                                      }
                                                                     });


    }
    else {
       if ($attr->has_read_method) {
           #TODO: couldn't this just be a before method modifier?
           $attr_class->add_around_method_modifier($attr->get_read_method, sub {
                                                                                my $orig = shift;
                                                                                my $self = shift;

                                                                                print "the named writer is running!\n";
                                                                                          
                                                                                return $attr->_get_fresh_value($self);
                                                                               });
       }

       if ($attr->has_write_method) {
           #TODO: couldn't this just be an after method modifier?
           $attr_class->add_around_method_modifier($attr->get_write_method, sub {
                                                                                 my $orig = shift;
                                                                                 my $self = shift;

                                                                                 my @args = @_;

                                                                                 print "the named writer is running!\n";

                                                                                 $attr->_reset__expiration_date();

                                                                                 return $self->$orig(@_);
                                                                                });
       }
    }

    if ($attr->predicate) {
         $attr_class->add_around_method_modifier($attr->predicate, sub { 
                                                                        my $orig = shift;
                                                                        my $self = shift;
                                                                        
                                                                        if ($attr->_is_expired()) {
                                                                            return '';
                                                                        }
                                                                        else {
                                                                            return $self->$orig();
                                                                        }
                                                                       });

    }

    if ($attr->clearer) {
         $attr_class->add_after_method_modifier($attr->clearer, sub { 
                                                                     my $self = shift;
   
                                                                     $attr->_clear__expiration_date();
                                                                    });
    }


};

sub _is_expired {
    my $attr = shift;
   
    return 0 unless $attr->has__expiration_date(); 

    my $now = DateTime->now();

    if ($now >= $attr->_expiration_date()) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _reset__expiration_date {
    my $attr = shift;

    #TODO: test this!
    return $attr->_expiration_date($attr->expires_at()) if $attr->has_expires_at();

    my $expires_date = DateTime->now();
   
    $expires_date->add($attr->expires_in());
          
    $attr->_expiration_date($expires_date);
  
    return 1;
}

sub _get_fresh_value {
    my ($attr, $container) = @_;

    if ($attr->_is_expired()) {
        $attr->clear_value($container);

        if ($attr->is_lazy()) {
            return $attr->get_value($container); 
        }
        else {
            # for non-lazy attributes I am just going to return the default, which may be undef.
            # Is this a good idea? It might be better to demand or assert laziness.
            return $attr->default();
        }
    }
    else {
        $attr->get_value($container);
    }
}

no Moose::Role;

1;

__END__

=pod

=head1 NAME

MooseX::Traits::Attribute::Expirable - Trait which ensures that a value from a set/build/default expires after a given set of time.

=head1 DESCRIPTION

This is a role which provides an expiration date which can be specified or calculated. An attribute's reader can safely be accessed without worrying about if it should be cleared and then run before hand. This is especially useful for costly build operations or attribute values that should be refreshed after a time duration, at a specific time or multiple specific times (such as every Monday at 8:00 am).

=head1 METHODS

=over 4

=item B<meta>

=back

=head1 AUTHOR

Kenny Flegal E<lt>soulstompp@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Kenny Flegal

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
