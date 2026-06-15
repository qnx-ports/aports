#ifndef ADJTIME_QNX_H
#define ADJTIME_QNX_H

/*
 * Emulate adjtime() using QNX ClockAdjust().
 * Chris Burghart <burghart@atd.ucar.edu>, 11/2001
 * Miroslaw Pabich <miroslaw_pabich@o2.pl>, 09/2005
 *
 * This is an implementation of adjtime() for QNX.  
 * ClockAdjust() is used to tweak the system clock for about
 * 1 second period until the desired delta is achieved.
 * Time correction slew is limited to reasonable value.
 * Internal rounding and relative errors are reduced.
 */

#include <sys/neutrino.h>
#include <sys/time.h>

/*
 * Time correction slew limit. QNX is a hard real-time system,
 * so don't adjust system clock too fast.
 */
#define CORR_SLEW_LIMIT     0.02  /* [s/s] */

/*
 * Period of system clock adjustment. It should be equal to adjtime
 * execution period (1s). If slightly less than 1s (0.95-0.99), then olddelta
 * residual error (introduced by execution period jitter) will be reduced.
 */
#define ADJUST_PERIOD       0.97  /* [s] */

int adjtime(struct timeval *delta, struct timeval *olddelta);

#ifdef ADJTIME_QNX_IMPLEMENTATION

  int 
adjtime (struct timeval *delta, struct timeval *olddelta)
{
  double delta_nsec;
  double delta_nsec_old;
  struct _clockadjust adj;
  struct _clockadjust oldadj;

  /*
   * How many nanoseconds are we adjusting?
   */
  if (delta != NULL)
    delta_nsec = 1e9 * (long)delta->tv_sec + 1e3 * delta->tv_usec;
  else
    delta_nsec = 0;

  /*
   * Build the adjust structure and call ClockAdjust()
   */
  if (delta_nsec != 0)
  {
    struct _clockperiod period;
    long count;
    long increment;
    long increment_limit;
    int isneg = 0;

    /*
     * Convert to absolute value for future processing
     */
    if (delta_nsec < 0)
    {
      isneg = 1;
      delta_nsec = -delta_nsec;
    }

    /*
     * Get the current clock period (nanoseconds)
     */
    if (ClockPeriod (CLOCK_REALTIME, 0, &period, 0) == -1)
      return -1;

    /*
     * Compute count and nanoseconds increment
     */
    count = 1e9 * ADJUST_PERIOD / period.nsec;
    increment = delta_nsec / count + .5;
    /* Reduce relative error */
    if (count > increment + 1)
    {
      increment = 1 + (long)((delta_nsec - 1) / count);
      count = delta_nsec / increment + .5;
    }

    /*
     * Limit the adjust increment to appropriate value
     */
    increment_limit = CORR_SLEW_LIMIT * period.nsec;
    if (increment > increment_limit)
    {
      increment = increment_limit;
      count = delta_nsec / increment + .5;
      /* Reduce relative error */
      if (increment > count + 1)
      {
        count =  1 + (long)((delta_nsec - 1) / increment);
        increment = delta_nsec / count + .5;
      }
    }

    adj.tick_nsec_inc = isneg ? -increment : increment;
    adj.tick_count = count;
  }
  else
  {
    adj.tick_nsec_inc = 0;
    adj.tick_count = 0;
  }

  if (ClockAdjust (CLOCK_REALTIME, &adj, &oldadj) == -1)
    return -1;

  /*
   * Build olddelta
   */
  delta_nsec_old = (double)oldadj.tick_count * oldadj.tick_nsec_inc;
  if (olddelta != NULL)
  {
    if (delta_nsec_old != 0)
    {
      /* Reduce rounding error */
      delta_nsec_old += (delta_nsec_old < 0) ? -500 : 500;
      olddelta->tv_sec = delta_nsec_old / 1e9;
      olddelta->tv_usec = (long)(delta_nsec_old - 1e9
          * (long)olddelta->tv_sec) / 1000;
    }
    else
    {
      olddelta->tv_sec = 0;
      olddelta->tv_usec = 0;
    }
  }

  return 0;
}
#endif // ADJTIME_QNX_IMPLEMENTATION

#endif // ADJTIME_QNX_H
