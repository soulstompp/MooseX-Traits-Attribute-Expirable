package MooseX::Traits::Attribute::Expirable;

use Moose::Role;

our $VERSION   = '0.01';

$VERSION = eval $VERSION;

our $AUTHORITY = 'cpan:soulstompp';

#TODO: reader method
#TODO: writer method
#TODO: do we need to consider timezones if this is going to be used on multiple machines (think KiokuDB).
with 'Moose::Meta::Attribute::Native::Trait';

use Moose::Meta::Attribute::Custom::MethodProvider::Expirable;

has 'method_provider' => (
                          is => 'ro',
                          isa       => 'ClassName',
                          predicate => 'has_method_provider',
                          default   => 'Moose::Meta::Attribute::Custom::MethodProvider::Expirable',
                         );

sub _default_is { 'ro' }
sub _helper_type { 'Any' }

has expiration_date => (
                        is => 'rw',
                        isa => 'Maybe[DateTime]',
                        clearer   => 'clear_expiration_date',
                        predicate => 'has_expiration_date',
                       );

#TODO: this needs a decent default.... probably a duration of 0 seconds
has expires_in => (
                   is        => 'rw',
                   isa       => 'DateTime::Duration',
                   predicate => 'has_expires_in',
                   clearer   => 'clear_expires_in',
                 );

#TODO: this should be 
has expires_at => (
                   is        => 'rw',
                   isa       => 'DateTime',
                   predicate => 'has_expires_at',
                   clearer   => 'clear_expires_at',
                  );

sub _build_expires_in {
    my $self = shift;

    return 0;
}

after install_accessors => sub {  
    my ($attribute, $inline) = @_;

    #TODO: make sure that we play nicely with inline operations.

    my $attribute_name = $attribute->name;
    my $attribute_class = $attribute->associated_class;
    my $attribute_meta = $attribute->meta;

    if ($attribute->get_read_method() eq $attribute->get_write_method()) {
        $attribute_class->add_around_method_modifier($attribute->accessor, sub {
                                                                                my $orig = shift;
                                                                                my $self = shift;

                                                                                my @args = @_;

                                                                                if (scalar @args) {
                                                                                   $attribute->_reset_expiration_date();
                                                                              
                                                                                   return $self->$orig(@_);
                                                                                }
                                                                                else {
                                                                                    if ($attribute->_is_expired()) {
                                                                                        $attribute->clear_value($self);

                                                                                        if ($attribute->is_lazy()) {
                                                                                            return $attribute->get_value($self); 
                                                                                        }
                                                                                        else {
                                                                                            # for non-lazy attributes I am just going to return the default, which may be undef.
                                                                                            # Is this a good idea? It might be better to demand or assert laziness.
                                                                                            return $attribute->default();
                                                                                        }
                                                                                    }
                                                                                   
                                                                                    return $self->$orig();
                                                                                }
                                                                          });


    }
    else {
       if ($attribute->has_read_method) {
           #TODO: couldn't this just be a before method modifier?
           $attribute_class->add_around_method_modifier($attribute->get_read_method, sub {
                                                                                          my $orig = shift;
                                                                                          my $self = shift;


                                                                                          die "named reader methods haven't been implemented yet";
                                                                                         });
       }

       if ($attribute->has_write_method) {
           #TODO: couldn't this just be an after method modifier?
           $attribute_class->add_around_method_modifier($attribute->get_write_method, sub {
                                                                                           my $orig = shift;
                                                                                           my $self = shift;

                                                                                           my @args = @_;

                                                                                           print "the named writer is running!\n";

                                                                                           $attribute->_reset_expiration_date();

                                                                                           return $self->$orig(@_);
                                                                                          });
       }
    }

    #TODO: test this!
    if ($attribute->predicate) {
         $attribute_class->add_around_method_modifier($attribute->predicate, sub { 
                                                                                  my $orig = shift;
                                                                                  my $self = shift;
                                                                                  
                                                                                  if ($attribute->_is_expired()) {
                                                                                      return 0;
                                                                                  }
                                                                                  else {
                                                                                      return $self->$orig();
                                                                                  }
                                                                                 });

    }

    #TODO: test this!
    if ($attribute->clearer) {
         $attribute_class->add_before_method_modifier($attribute->clearer, sub { 
                                                                                my $self = shift;
   
                                                                                $attribute->_clear_expiration_date();
                                                                               });


    }
};

sub _is_expired {
    my $attribute = shift;
   
    return undef unless defined $attribute->expiration_date(); 

    my $now = DateTime->now();

    if ($now >= $attribute->expiration_date()) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _reset_expiration_date {
    my $attribute = shift;

    #TODO: test this!
    return $attribute->expiration_date($attribute->expires_at()) if $attribute->has_expires_at();

    my $expires_date = DateTime->now();
   
    $expires_date->add($attribute->expires_in());
          
    $attribute->expiration_date($expires_date);
  
    return 1;
}

no Moose::Role;

1;
