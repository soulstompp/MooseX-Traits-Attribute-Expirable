package MooseX::Traits::Attribute::Expirable;

use Moose::Role;

our $VERSION   = '1.12';

$VERSION = eval $VERSION;

our $AUTHORITY = 'cpan:soulstompp';

has expires_in => (
                   is        => 'rw',
                   isa       => 'DateTime::Duration',
                   predicate => 'has_expires_in',
                   default   => 0,
                   clearer   => 'clear_expires_in',
                 );

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
    my ($self, $inline) = @_;

    my $attribute = $self;
    my $attribute_name = $self->name;
    my $attribute_class = $self->associated_class;
    my $attribute_meta = $self->meta;

    if ($self->get_read_method() eq $self->get_write_method()) {
        $attribute_class->add_around_method_modifier($self->accessor, sub {
                                                                           my $orig = shift;
                                                                           my $self = shift;

                                                                           my @args = @_;

                                                                           if (scalar @args) {
                                                                               my $expires_date = DateTime->now();
    
                                                                               $expires_date->add($attribute->expires_in());
                                                                                       
                                                                               $attribute->expires_at($expires_date);

                                                                               return $self->$orig(@_);
                                                                           }
                                                                           else {
                                                                               return unless $attribute->has_expires_at();

                                                                               if (_attribute_has_expired($attribute)) {
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
       if ($self->has_read_method) {
           $attribute_class->add_around_method_modifier($self->get_read_method, sub {
                                                                                     die "named reader methods haven't been implemented yet";
                                                                                    });
       }

       if ($self->has_write_method) {
           $attribute_class->add_around_method_modifier($self->get_write_method, sub {
                                                                                      die "named reader methods haven't been implemented yet";
                                                                                     });
       }
    }

    if ($self->predicate) {
         $attribute_class->add_around_method_modifier($self->predicate, sub { 
                                                                             my $orig = shift;
                                                                             my $self = shift;
                                                                             
                                                                             return $self->$orig() unless $self->has_expires_at();

                                                                             if ($self->_attribute_has_expired($attribute)) {
                                                                                 return 0;
                                                                             }
                                                                             else {
                                                                                 return $self->$orig();
                                                                             }
                                                                            });

    }

    if ($self->clearer) {
         $attribute_class->add_before_method_modifier($self->clearer, sub { 
                                                                           my $self = shift;

                                                                           $self->_clear_expires_at();
                                                                            
                                                                           print "i am after the write\n";
                                                                          });


    }
};


sub _attribute_has_expired {
    my ($attribute) = @_;
    
    my $now = DateTime->now();

    if ($now >= $attribute->expires_at()) {
        return 1;
    }
    else {
        return 0;
    }
}

no Moose::Role;

1;
