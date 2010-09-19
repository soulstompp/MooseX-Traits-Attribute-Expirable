package Moose::Meta::Attribute::Custom::MethodProvider::Expirable;

use Moose::Role;

our $VERSION   = '0.01';
$VERSION = eval $VERSION;
our $AUTHORITY = 'cpan:soulstompp';

#TODO: this will eventually be our expire method

sub expire : method {
    my ( $attr, $reader, $writer ) = @_;

    my $now = DateTime->now();
    #TODO: this has to support builders as well.
    #TODO: shouldn't this clear expires_at?
    return sub { $attr->expiration_date($now) };
}

1;

__END__

=pod

=head1 NAME

Moose::Meta::Attribute::Native::MethodProvider::Counter - role providing method generators for Counter trait

=head1 DESCRIPTION

This is a role which provides the method generators for
L<Moose::Meta::Attribute::Native::Trait::Counter>.  Please check there for
documentation on what methods are provided.

=head1 METHODS

=over 4

=item B<meta>

=back

=head1 BUGS

See L<Moose/BUGS> for details on reporting bugs.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2009 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
