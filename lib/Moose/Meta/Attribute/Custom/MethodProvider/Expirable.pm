package Moose::Meta::Attribute::Custom::MethodProvider::Expirable;

use Moose::Role;

our $VERSION   = '0.01';
$VERSION = eval $VERSION;
our $AUTHORITY = 'cpan:soulstompp';

sub expire : method {
    my ( $attr, $reader, $writer ) = @_;

    my $now = DateTime->now();
    
    $attr->clear_expires_at();
    return sub { $attr->expiration_date($now) };
}

sub expire_at : method {
    my ( $attr, $reader, $writer ) = @_;

    return sub { $attr->expires_at($_[1]) };
}

1;

__END__

=pod

=head1 NAME

Moose::Meta::Attribute::Custom::MethodProvider::Expirable - role providing method generators for Expirable trait

=head1 DESCRIPTION

This is a role which provides the method generators for
L<Moose::Meta::Attribute::Custom::Trait::Expirable>.  Please check there for
documentation on what methods are provided.

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
