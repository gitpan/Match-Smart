#!/usr/bin/perl


use 5.010;
use strict;
use warnings;

use Test::More 0.88;
#use Test::NoWarnings;
use Match::Smart -all;

sub matches {
	my ($left, $right, $message) = @_;
	local $Test::Builder::Level = $Test::Builder::Level + 1;
	return ok($left ~~ $right, $message);
}

sub nonmatches {
	my ($left, $right, $message) = @_;
	local $Test::Builder::Level = $Test::Builder::Level + 1;
	return ok(not($left ~~ $right), $message);
}

matches(1, always, '1 matches always');
matches(undef, always, 'undef matches always');
nonmatches(1, never, '1 doesn\'t match never');
nonmatches(undef, never, 'undef doesn\'t match never');

matches(1, true, '1 is true');
matches('foo', true, '\'foo\' is true');
matches(0, false, '0 is false');
matches('', false, '\'\' is false');

matches(1, number, '1 is a number');
matches(1, integer, '1 is an integer');
nonmatches('foo', number, '\'foo\' is not a number');
nonmatches(1.5, integer, '1.5 is not an integer');
matches(1, odd, '1 is odd');
nonmatches(2, odd, '2 is not odd');
matches(1, positive, '1 is positive');
matches(1, range(0,1), '1 is in range 0..1');
nonmatches(42, range(0,13), '42 is not in range(0,13)');

matches(1, any(1,2,3), '1 is any(1,2,3)');
nonmatches(1, any(2,3), '1 is not any(2,3)');
matches(1, all(1, number, positive), '1 is all(1, number, positive)');
nonmatches(1, all(1, number, negative), '1 is not all(1, number, negative)');
matches(1, none('a', 2, []), '1 matches none(\'a\', 2, [])');
nonmatches(1, none('a', 1, []), '1 doesn\'t match none(\'a\', 1, [])');
matches(1, one(odd, even, negative), '1 matches one(odd, even, negative)');
nonmatches(1, one(odd, even, positive), '1 doesn\'t match one(odd, even, positive)');

matches(1, numwise(1), '1 is numwise(1)');
matches('0001', numwise(1), '1 is numwise(1)');
nonmatches(2, numwise(3), '2 is not numwise(3)');
nonmatches('foo', numwise(1), '\'foo\' is not numwise(1)');

matches(1, string, '1 is a string');
matches('foo', string, '\'foo\' is a string');
nonmatches([ 1 ], string, '[ 1 ] is not a string');

matches('foo', stringwise('foo'), '\'foo\' is stringwise(\'foo\')');
nonmatches('foo', stringwise('bar'), '\'foo\' is not stringwise(\'bar\')');
nonmatches(1, stringwise('01'), '1 is not stringwise(\'01\')');

matches('foo', string_length(3), '\'foo\' is string_length(3)');
matches('foo', string_length(odd), '\'foo\' is string_length(odd)');
nonmatches('foo', string_length(negative), '\'foo\' is not string_length(negative)');

matches(bless([], 'main'), object, 'bless([], \'main\')is an object');
nonmatches('foo', object, '\'foo\' is not an object');

matches([ 1 ], array, '[ 1 ] is an array');
nonmatches([ 1 ], tuple(2), '[ 1 ] is not tuple(2)');
matches([ 1 ], tuple(1), '[ 1 ] is tuple(1)');
matches([ 1 ], tuple(number), '[ 1 ] is tuple(number)');
matches([ 1, 2, 3 ], array_length(3), '[ 1, 2, 3 ] matches array_length(3)');

matches([ 1, 2, 3 ], head(1, 2, 3), '[ 1, 2, 3 ] is head(1,2,3)');
matches([ 1, 2, 3 ], head(1, 2), '[ 1, 2, 3 ] is head(1,2)');
matches([ 1, 2, 3 ], head(1), '[ 1, 2, 3 ] is head(1)');
nonmatches([ 1, 2 ], head(1, 2, 3), '[ 1, 2, 3 ] is head(1,2,3)');
nonmatches([ 1, 2, 4 ], head(1, 2, 3), '[ 1, 2, 3 ] is head(1,2,3)');

matches([ 1, 2, 3 ], sequence(number), '[ 1, 2, 3 ] is a sequence(number)');
nonmatches([ 1, 2, 'a' ], sequence(number), '[ 1, 2, \'a\' ] is a sequence(number)');

matches({}, hash, '{} is a hash');
nonmatches([], hash, '[] is not a hash');
matches({ foo => 1, bar => 2 }, hash_keys([qw/bar foo/]), '{ foo => 1, bar => 2 } matches hash_keys([qw/bar foo/])');
nonmatches({ foo => 1, baz => 2 }, hash_keys([qw/bar foo/]), '{ foo => 1, baz => 2 } doesn\'t match hash_keys([qw/bar foo/])');

for (1) {
	when(always) {
		pass('Works in boolean context');
	}
	default {
		fail('Works in boolean context');
	}
}

for (1) {
	when(false) {
		fail('Works in boolean context part two');
	}
	default {
		pass('Works in boolean context part two');
	}
}

for (1) {
	when(any(number)) {
		pass('Works in boolean context part three');
	}
	default {
		fail('Works in boolean context part three');
	}
}

given (1) {
	when(any(number)) {
		pass('Works in boolean context part three');
	}
	default {
		fail('Works in boolean context part three');
	}
}

done_testing;
