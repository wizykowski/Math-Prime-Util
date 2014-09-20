#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Math::Prime::Util qw/bernfrac bernreal/;
my $extra = defined $ENV{EXTENDED_TESTING} && $ENV{EXTENDED_TESTING};

my @A000367 = (qw/1 1 -1 1 -1 5 -691 7 -3617 43867 -174611 854513 -236364091 8553103 -23749461029 8615841276005 -7709321041217 2577687858367 -26315271553053477373 2929993913841559 -261082718496449122051 1520097643918070802691 -27833269579301024235023 596451111593912163277961 -5609403368997817686249127547 495057205241079648212477525 -801165718135489957347924991853 29149963634884862421418123812691 -2479392929313226753685415739663229 84483613348880041862046775994036021 -1215233140483755572040304994079820246041491/);
my @A002445 = (qw/1 6 30 42 30 66 2730 6 510 798 330 138 2730 6 870 14322 510 6 1919190 6 13530 1806 690 282 46410 66 1590 798 870 354 56786730 6 510 64722 30 4686 140100870 6 30 3318 230010 498 3404310 6 61410 272118 1410 6 4501770 6 33330 4326 1590 642 209191710 1518 1671270 42/);

my $ntests = $extra ? 30 : 10;

plan tests => 2 + 1+$ntests + 1;

{
  my(@num, @den);
  for (0 .. $ntests) {
    my($n,$d) = bernfrac(2*$_);
    push @num, $n;
    push @den, $d;
  }
  $#A000367 = $#num;
  $#A002445 = $#den;
  # This is too slow:
  #my @num = map { (bernfrac(2*$_))[0] }  0 .. $#A000367;
  #my @den = map { (bernfrac(2*$_))[1] }  0 .. $#A002445;
  is_deeply( \@num, \@A000367, "B_2n numerators 0 .. $#A000367" );
  is_deeply( \@den, \@A002445, "B_2n denominators 0 .. $#A002445" );
  for my $k (0 .. $ntests) {
    cmp_closeto(bernreal(2*$k), "$num[$k]" / "$den[$k]", 1e-8, "bernreal(2*$k)");
  }
}

cmp_closeto( bernreal(1), 0.5, 1e-8, "bernreal(1)" );


sub cmp_closeto {
  my $got = shift;
  my $expect = shift;
  my $tolerance = shift;
  my $message = shift;
  cmp_ok( abs($got - $expect), '<=', $tolerance, $message );
}
