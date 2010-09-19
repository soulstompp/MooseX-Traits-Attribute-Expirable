package Moose::Meta::Attribute::Custom::Trait::Expirable;

use Moose::Role;

with 'Moose::Meta::Attribute::Native::Trait';

sub register_implementation { 'MooseX::Traits::Attribute::Expirable' }

no Moose::Role;

1;

__END__

=pod

=head1 NAME

Moose::Meta::Attribute::Native::Trait::Counter - Helper trait for counters

=head1 SYNOPSIS

=head1 DESCRIPTION

This module provides a simple counter attribute, which can be
incremented and decremented by arbitrary amounts.  The default
amount of change is one.

=head1 PROVIDED METHODS

These methods are implemented in
L<Moose::Meta::Attribute::Native::MethodProvider::Counter>. It is important to
note that all those methods do in place modification of the value stored in
the attribute.

=head1 METHODS

=over 4

=item B<meta>

=item B<method_provider>

=item B<has_method_provider>

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
