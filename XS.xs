
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
/* We're not using anything for which we need ppport.h */
#include "ptypes.h"
#include "cache.h"
#include "sieve.h"
#include "util.h"
#include "factor.h"

MODULE = Math::Prime::Util	PACKAGE = Math::Prime::Util

PROTOTYPES: ENABLE


void
prime_precalc(IN UV n)

void
prime_memfree()

void
_prime_memfreeall()

UV
_XS_prime_count(IN UV low, IN UV high = 0)
  CODE:
    if (high == 0) {   /* Without a Perl layer in front of this, we'll have */
      high = low;      /* the pathological case of a-0 turning into 0-a.    */
      low = 0;
    }
    if (GIMME_V == G_VOID) {
      prime_precalc(high);
      RETVAL = 0;
    } else {
      RETVAL = _XS_prime_count(low, high);
    }
  OUTPUT:
    RETVAL

UV
_XS_nth_prime(IN UV n)

int
_XS_is_prime(IN UV n)

UV
_XS_next_prime(IN UV n)

UV
_XS_prev_prime(IN UV n)


UV
_get_prime_cache_size()
  CODE:
    RETVAL = get_prime_cache(0, 0);
  OUTPUT:
    RETVAL

int
_XS_prime_maxbits()
  CODE:
    RETVAL = BITS_PER_WORD;
  OUTPUT:
    RETVAL


SV*
sieve_primes(IN UV low, IN UV high)
  PREINIT:
    const unsigned char* sieve;
    AV* av = newAV();
  CODE:
    if (low <= high) {
      if (get_prime_cache(high, &sieve) < high) {
        release_prime_cache(sieve);
        croak("Could not generate sieve for %"UVuf, high);
      } else {
        if ((low <= 2) && (high >= 2)) { av_push(av, newSVuv( 2 )); }
        if ((low <= 3) && (high >= 3)) { av_push(av, newSVuv( 3 )); }
        if ((low <= 5) && (high >= 5)) { av_push(av, newSVuv( 5 )); }
        if (low < 7) { low = 7; }
        START_DO_FOR_EACH_SIEVE_PRIME( sieve, low, high ) {
           av_push(av,newSVuv(p));
        } END_DO_FOR_EACH_SIEVE_PRIME
        release_prime_cache(sieve);
      }
    }
    RETVAL = newRV_noinc( (SV*) av );
  OUTPUT:
    RETVAL


SV*
trial_primes(IN UV low, IN UV high)
  PREINIT:
    UV  curprime;
    AV* av = newAV();
  CODE:
    if (low <= high) {
      if (low >= 2) low--;   /* Make sure low gets included */
      curprime = _XS_next_prime(low);
      while (curprime <= high) {
        av_push(av,newSVuv(curprime));
        curprime = _XS_next_prime(curprime);
      }
    }
    RETVAL = newRV_noinc( (SV*) av );
  OUTPUT:
    RETVAL

SV*
segment_primes(IN UV low, IN UV high);
  PREINIT:
    AV* av = newAV();
  CODE:
    if ((low <= 2) && (high >= 2)) { av_push(av, newSVuv( 2 )); }
    if ((low <= 3) && (high >= 3)) { av_push(av, newSVuv( 3 )); }
    if ((low <= 5) && (high >= 5)) { av_push(av, newSVuv( 5 )); }
    if (low < 7)  low = 7;
    if (low <= high) {
      /* Call the segment siever one or more times */
      UV low_d, high_d, segment_size;
      unsigned char* sieve = get_prime_segment(&segment_size);
      if (sieve == 0)
        croak("Could not get segment cache");

      /* To protect vs. overflow, work entirely with d. */
      low_d  = low  / 30;
      high_d = high / 30;

      {  /* Avoid recalculations of this */
        UV endp = (high_d >= (UV_MAX/30))  ?  UV_MAX-2  :  30*high_d+29;
        prime_precalc( sqrt(endp) + 0.1 + 1 );
      }

      while ( low_d <= high_d ) {
        UV seghigh_d = ((high_d - low_d) < segment_size)
                       ? high_d
                       : (low_d + segment_size-1);
        UV range_d = seghigh_d - low_d + 1;
        UV seghigh = (seghigh_d == high_d) ? high : (seghigh_d*30+29);
        UV segbase = low_d * 30;
        /* printf("  startd = %"UVuf"  endd = %"UVuf"\n", startd, endd); */

        MPUassert( seghigh_d >= low_d, "segment_primes highd < lowd");
        MPUassert( range_d <= segment_size, "segment_primes range > segment size");

        /* Sieve from startd*30+1 to endd*30+29.  */
        if (sieve_segment(sieve, low_d, seghigh_d) == 0) {
          release_prime_segment(sieve);
          croak("Could not segment sieve from %"UVuf" to %"UVuf, segbase+1, seghigh);
        }

        START_DO_FOR_EACH_SIEVE_PRIME( sieve, low - segbase, seghigh - segbase )
          av_push(av,newSVuv( segbase + p ));
        END_DO_FOR_EACH_SIEVE_PRIME

        low_d += range_d;
        low = seghigh+2;
      }
      release_prime_segment(sieve);
    }
    RETVAL = newRV_noinc( (SV*) av );
  OUTPUT:
    RETVAL

SV*
erat_primes(IN UV low, IN UV high)
  PREINIT:
    unsigned char* sieve;
    AV* av = newAV();
  CODE:
    if (low <= high) {
      sieve = sieve_erat30(high);
      if (sieve == 0) {
        croak("Could not generate sieve for %"UVuf, high);
      } else {
        if ((low <= 2) && (high >= 2)) { av_push(av, newSVuv( 2 )); }
        if ((low <= 3) && (high >= 3)) { av_push(av, newSVuv( 3 )); }
        if ((low <= 5) && (high >= 5)) { av_push(av, newSVuv( 5 )); }
        if (low < 7) { low = 7; }
        START_DO_FOR_EACH_SIEVE_PRIME( sieve, low, high ) {
           av_push(av,newSVuv(p));
        } END_DO_FOR_EACH_SIEVE_PRIME
        Safefree(sieve);
      }
    }
    RETVAL = newRV_noinc( (SV*) av );
  OUTPUT:
    RETVAL


void
_XS_factor(IN UV n)
  PPCODE:
    if (n < 4) {                        /* If n is 0-3, we're done. */
      XPUSHs(sv_2mortal(newSVuv( n )));
    } else if (n < 2000000) {           /* For small n, just trial division */
      int i;
      UV facs[32];  /* maximum number of factors is log2n */
      UV nfacs = trial_factor(n, facs, 0);
      for (i = 1; i <= nfacs; i++) {
        XPUSHs(sv_2mortal(newSVuv( facs[i-1] )));
      }
    } else {
      int const verbose = 0;
      UV const tlim_lower = 211;  /* Trial division through this prime */
      UV const tlim = 223;        /* This means we've checked through here */
      UV tofac_stack[MPU_MAX_FACTORS+1];
      UV factored_stack[MPU_MAX_FACTORS+1];
      int ntofac = 0;
      int nfactored = 0;

      { /* Trial division, removes all factors below tlim */
        int i;
        UV facs[BITS_PER_WORD+1];
        UV nfacs = trial_factor(n, facs, tlim_lower);
        for (i = 1; i < nfacs; i++) {
          XPUSHs(sv_2mortal(newSVuv( facs[i-1] )));
        }
        n = facs[nfacs-1];
      }

      do { /* loop over each remaining factor */
        /* In theory we can try to minimize work using is_definitely_prime(n)
         * but in practice it seems slower. */
        while ( (n >= (tlim*tlim)) && (!_XS_is_prime(n)) ) {
          int split_success = 0;
          /* Adjust the number of rounds based on the number size */
          UV br_rounds = ((n>>29) < 100000) ?  1500 :  1500;
          UV sq_rounds = 80000; /* 20k 91%, 40k 98%, 80k 99.9%, 120k 99.99% */

          /* About 94% of random inputs are factored with this pbrent call */
          if (!split_success) {
            split_success = pbrent_factor(n, tofac_stack+ntofac, br_rounds)-1;
            if (verbose) { if (split_success) printf("pbrent 1:  %"UVuf" %"UVuf"\n", tofac_stack[ntofac], tofac_stack[ntofac+1]); else printf("pbrent 0\n"); }
          }

          if (!split_success && n < (UV_MAX>>3)) {
            /* SQUFOF with these parameters gets 95% of what's left. */
            split_success = racing_squfof_factor(n, tofac_stack+ntofac, sq_rounds)-1;
            if (verbose) printf("squfof %d\n", split_success);
          }

          /* Perhaps prho using different parameters will find it */
          if (!split_success) {
            split_success = prho_factor(n, tofac_stack+ntofac, 800)-1;
            if (verbose) printf("prho %d\n", split_success);
          }

          /* This p-1 gets about 2/3 of what makes it through the above */
          if (!split_success) {
            split_success = pminus1_factor(n, tofac_stack+ntofac, 4000, 40000)-1;
            if (verbose) printf("pminus1 %d\n", split_success);
          }

          /* Some rounds of HOLF, good for close to perfect squares */
          if (!split_success) {
            split_success = holf_factor(n, tofac_stack+ntofac, 2000)-1;
            if (verbose) printf("holf %d\n", split_success);
          }

          /* Less than 0.1% of random inputs make it here */
          if (!split_success) {
            split_success = prho_factor(n, tofac_stack+ntofac, 256*1024)-1;
            if (verbose) printf("long prho %d\n", split_success);
          }

          if (split_success) {
            MPUassert( split_success == 1, "split factor returned more than 2 factors");
            ntofac++; /* Leave one on the to-be-factored stack */
            if ((tofac_stack[ntofac] == n) || (tofac_stack[ntofac] == 1))
              croak("bad factor\n");
            n = tofac_stack[ntofac];  /* Set n to the other one */
          } else {
            /* Factor via trial division.  Nothing should make it here. */
            UV f = tlim;
            UV m = tlim % 30;
            UV limit = (UV) (sqrt(n)+0.1);
            if (verbose) printf("doing trial on %"UVuf"\n", n);
            while (f <= limit) {
              if ( (n%f) == 0 ) {
                do {
                  n /= f;
                  factored_stack[nfactored++] = f;
                } while ( (n%f) == 0 );
                limit = (UV) (sqrt(n)+0.1);
              }
              f += wheeladvance30[m];
              m =  nextwheel30[m];
            }
            break;  /* We just factored n via trial division.  Exit loop. */
          }
        }
        /* n is now prime (or 1), so add to already-factored stack */
        if (n != 1)  factored_stack[nfactored++] = n;
        /* Pop the next number off the to-factor stack */
        if (ntofac > 0)  n = tofac_stack[ntofac-1];
      } while (ntofac-- > 0);
      /* Now push all the factored results in sorted order */
      {
        int i, j;
        for (i = 0; i < nfactored; i++) {
          int mini = i;
          for (j = i+1; j < nfactored; j++)
            if (factored_stack[j] < factored_stack[mini])
              mini = j;
          if (mini != i) {
            UV t = factored_stack[mini];
            factored_stack[mini] = factored_stack[i];
            factored_stack[i] = t;
          }
          XPUSHs(sv_2mortal(newSVuv( factored_stack[i] )));
        }
      }
    }

#define SIMPLE_FACTOR(func, n, rounds) \
    if (n <= 1) { \
      XPUSHs(sv_2mortal(newSVuv( n ))); \
    } else { \
      while ( (n% 2) == 0 ) {  n /=  2;  XPUSHs(sv_2mortal(newSVuv( 2 ))); } \
      while ( (n% 3) == 0 ) {  n /=  3;  XPUSHs(sv_2mortal(newSVuv( 3 ))); } \
      while ( (n% 5) == 0 ) {  n /=  5;  XPUSHs(sv_2mortal(newSVuv( 5 ))); } \
      if (n == 1) {  /* done */ } \
      else if (_XS_is_prime(n)) { XPUSHs(sv_2mortal(newSVuv( n ))); } \
      else { \
        UV factors[MPU_MAX_FACTORS+1]; \
        int i, nfactors; \
        nfactors = func(n, factors, rounds); \
        for (i = 0; i < nfactors; i++) { \
          XPUSHs(sv_2mortal(newSVuv( factors[i] ))); \
        } \
      } \
    }

void
trial_factor(IN UV n, IN UV maxfactor = 0)
  PPCODE:
    SIMPLE_FACTOR(trial_factor, n, maxfactor);

void
fermat_factor(IN UV n, IN UV maxrounds = 64*1024*1024)
  PPCODE:
    SIMPLE_FACTOR(fermat_factor, n, maxrounds);

void
holf_factor(IN UV n, IN UV maxrounds = 8*1024*1024)
  PPCODE:
    SIMPLE_FACTOR(holf_factor, n, maxrounds);

void
squfof_factor(IN UV n, IN UV maxrounds = 4*1024*1024)
  PPCODE:
    SIMPLE_FACTOR(squfof_factor, n, maxrounds);

void
rsqufof_factor(IN UV n, IN UV maxrounds = 4*1024*1024)
  PPCODE:
    SIMPLE_FACTOR(racing_squfof_factor, n, maxrounds);

void
pbrent_factor(IN UV n, IN UV maxrounds = 4*1024*1024)
  PPCODE:
    SIMPLE_FACTOR(pbrent_factor, n, maxrounds);

void
prho_factor(IN UV n, IN UV maxrounds = 4*1024*1024)
  PPCODE:
    SIMPLE_FACTOR(prho_factor, n, maxrounds);

void
pminus1_factor(IN UV n, IN UV B1 = 1*1024*1024, IN UV B2 = 0)
  PPCODE:
    if (B2 == 0)
      B2 = 10*B1;
    if (n <= 1) {
      XPUSHs(sv_2mortal(newSVuv( n )));
    } else {
      while ( (n% 2) == 0 ) {  n /=  2;  XPUSHs(sv_2mortal(newSVuv( 2 ))); }
      while ( (n% 3) == 0 ) {  n /=  3;  XPUSHs(sv_2mortal(newSVuv( 3 ))); }
      while ( (n% 5) == 0 ) {  n /=  5;  XPUSHs(sv_2mortal(newSVuv( 5 ))); }
      if (n == 1) {  /* done */ }
      else if (_XS_is_prime(n)) { XPUSHs(sv_2mortal(newSVuv( n ))); }
      else {
        UV factors[MPU_MAX_FACTORS+1];
        int i, nfactors;
        nfactors = pminus1_factor(n, factors, B1, B2);
        for (i = 0; i < nfactors; i++) {
          XPUSHs(sv_2mortal(newSVuv( factors[i] )));
        }
      }
    }

int
_XS_miller_rabin(IN UV n, ...)
  PREINIT:
    UV bases[64];
    int prob_prime = 1;
    int c = 1;
  CODE:
    if (items < 2)
      croak("No bases given to miller_rabin");
    if ( (n == 0) || (n == 1) ) XSRETURN_IV(0);   /* 0 and 1 are composite */
    if ( (n == 2) || (n == 3) ) XSRETURN_IV(1);   /* 2 and 3 are prime */
    if (( n % 2 ) == 0)  XSRETURN_IV(0);          /* MR works with odd n */
    while (c < items) {
      int b = 0;
      while (c < items) {
        bases[b++] = SvUV(ST(c));
        c++;
        if (b == 64) break;
      }
      prob_prime = _XS_miller_rabin(n, bases, b);
      if (prob_prime != 1)
        break;
    }
    RETVAL = prob_prime;
  OUTPUT:
    RETVAL

int
_XS_is_prob_prime(IN UV n)

double
_XS_ExponentialIntegral(double x)

double
_XS_LogarithmicIntegral(double x)

double
_XS_RiemannZeta(double x)
  CODE:
    RETVAL = (double) ld_riemann_zeta(x);
  OUTPUT:
    RETVAL

double
_XS_RiemannR(double x)
