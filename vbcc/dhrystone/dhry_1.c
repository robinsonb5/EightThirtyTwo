/*
 ****************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *                                                                            
 *  Version:    C, Version 2.1
 *                                                                            
 *  File:       dhry_1.c (part 2 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 ****************************************************************************
 */

#define __extension__ 
#include "dhry.h"
//#include <sys/null.h>
#include <sys/types.h>
#include <string.h>
#include <stdarg.h>
#include "small_printf.h"
#include "timer.h"

/* Global Variables: */

Rec_Pointer     Ptr_Glob,
                Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
char            Ch_1_Glob,
                Ch_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];

Enumeration     Func_1 ();
  /* forward declaration necessary since Enumeration may not simply be int */

#ifndef REG
        Boolean Reg = false;
#define REG
        /* REG becomes defined as empty */
        /* i.e. no register variables   */
#else
        Boolean Reg = true;
#endif

/* variables for time measurement: */

#ifdef TIMES
// struct tms      time_info;
                /* see library function "times" */
#define Too_Small_Time 120
                /* Measurements should last at least about 2 seconds */
#endif
#ifdef TIME
extern long     time();
                /* see library function "time"  */
#define Too_Small_Time 2
                /* Measurements should last at least 2 seconds */
#endif

long           Begin_Time,
                End_Time,
                User_Time;
long            Microseconds,
                Dhrystones_Per_Second,
                Vax_Mips;
                
/* end of variables for time measurement */

int             Number_Of_Runs = 1;

long _readMilliseconds()
{
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	unsigned int i=HW_TIMER(REG_MILLISECONDS);
	unsigned int result=(i>>24)&0xff;
	result|=(i>>8)&0xff00;
	result|=(i<<8)&0xff0000;
	result|=(i<<24)&0xff00000;
	return(result);
#else
	return(HW_TIMER(REG_MILLISECONDS));
#endif
}

#if 0
#define strcpy _strcpy

_strcpy(char *dst,const char *src)
{
	while(*dst++=*src++);
}
#endif

Rec_Type rec1;
Rec_Type rec2;


// Keep anything remotely large off the stack...
Str_30          Str_1_Loc;
Str_30          Str_2_Loc;

int main ()
/*****/

  /* main program, corresponds to procedures        */
  /* Main and Proc_0 in the Ada version             */
{
        One_Fifty       Int_1_Loc;
  REG   One_Fifty       Int_2_Loc;
        One_Fifty       Int_3_Loc;
  REG   char            Ch_Index;
        Enumeration     Enum_Loc;
  REG   int             Run_Index;

  /* Initializations */

//  Next_Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
//  Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));

  Next_Ptr_Glob = &rec1;
  Ptr_Glob = &rec2;

  Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
  Ptr_Glob->Discr                       = Ident_1;
  Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
  Ptr_Glob->variant.var_1.Int_Comp      = 40;
  strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
          "DHRYSTONE PROGRAM, SOME STRING");
  strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

  Arr_2_Glob [8][7] = 10;
        /* Was missing in published program. Without this statement,    */
        /* Arr_2_Glob [8][7] would have an undefined value.             */
        /* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
        /* overflow may occur for this array element.                   */
  small_printf ("\n");
  small_printf ("Dhrystone Benchmark, Version 2.1 (Language: C)\n");
  small_printf ("\n");
  if (Reg)
  {
    small_printf ("Program compiled with 'register' attribute\n");
    small_printf ("\n");
  }
  else
  {
    small_printf ("Program compiled without 'register' attribute\n");
    small_printf ("\n");
  }
  Number_Of_Runs;

  small_printf ("Execution starts, %d runs through Dhrystone\n", Number_Of_Runs);

  /***************/
  /* Start timer */
  /***************/

#if 0
#ifdef TIMES
  times (&time_info);
  Begin_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  Begin_Time = time ( (long *) 0);
#endif
#else
  Begin_Time = _readMilliseconds();
#endif
  for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
  {
	puts("5\n");
    Proc_5();
	puts("4\n");
    Proc_4();
      /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
    Int_1_Loc = 2;
    Int_2_Loc = 3;
	puts("2\n");
    strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
	puts("2.1\n");
    Enum_Loc = Ident_2;
	puts("2.2\n");
    Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
      /* Bool_Glob == 1 */
	puts("1\n");
    while (Int_1_Loc < Int_2_Loc)  /* loop body executed once */
    {
      Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
        /* Int_3_Loc == 7 */
      Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
        /* Int_3_Loc == 7 */
      Int_1_Loc += 1;
    } /* while */
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
	puts("A\n");
    Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
      /* Int_Glob == 5 */
	puts("B\n");
    Proc_1 (Ptr_Glob);
    for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
                             /* loop body executed twice */
    {
      if (Enum_Loc == Func_1 (Ch_Index, 'C'))
          /* then, not executed */
        {
        Proc_6 (Ident_1, &Enum_Loc);
        strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
        Int_2_Loc = Run_Index;
        Int_Glob = Run_Index;
        }
    }
	puts("C\n");
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Int_2_Loc = Int_2_Loc * Int_1_Loc;
    Int_1_Loc = Int_2_Loc / Int_3_Loc;
    Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
      /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
    Proc_2 (&Int_1_Loc);
      /* Int_1_Loc == 5 */

  } /* loop "for Run_Index" */

  /**************/
  /* Stop timer */
  /**************/
  
#if 0
#ifdef TIMES
  times (&time_info);
  End_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  End_Time = time ( (long *) 0);
#endif
#else
  End_Time = _readMilliseconds();
#endif

#if 1
  small_printf ("Execution ends\n");
  small_printf ("\n");
  small_printf ("Final values of the variables used in the benchmark:\n");
  small_printf ("\n");
  small_printf ("Int_Glob:            %d\n", Int_Glob);
  small_printf ("        should be:   %d\n", 5);
  small_printf ("Bool_Glob:           %d\n", Bool_Glob);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("Ch_1_Glob:           %c\n", Ch_1_Glob);
  small_printf ("        should be:   %c\n", 'A');
  small_printf ("Ch_2_Glob:           %c\n", Ch_2_Glob);
  small_printf ("        should be:   %c\n", 'B');
  small_printf ("Arr_1_Glob[8]:       %d\n", Arr_1_Glob[8]);
  small_printf ("        should be:   %d\n", 7);
  small_printf ("Arr_2_Glob[8][7]:    %d\n", Arr_2_Glob[8][7]);
  small_printf ("        should be:   Number_Of_Runs + 10\n");
  small_printf ("Ptr_Glob->\n");
  small_printf ("  Ptr_Comp:          %d\n", (int) Ptr_Glob->Ptr_Comp);
  small_printf ("        should be:   (implementation-dependent)\n");
  small_printf ("  Discr:             %d\n", Ptr_Glob->Discr);
  small_printf ("        should be:   %d\n", 0);
  small_printf ("  Enum_Comp:         %d\n", Ptr_Glob->variant.var_1.Enum_Comp);
  small_printf ("        should be:   %d\n", 2);
  small_printf ("  Int_Comp:          %d\n", Ptr_Glob->variant.var_1.Int_Comp);
  small_printf ("        should be:   %d\n", 17);
  small_printf ("  Str_Comp:          %s\n", Ptr_Glob->variant.var_1.Str_Comp);
  small_printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  small_printf ("Next_Ptr_Glob->\n");
  small_printf ("  Ptr_Comp:          %d\n", (int) Next_Ptr_Glob->Ptr_Comp);
  small_printf ("        should be:   (implementation-dependent), same as above\n");
  small_printf ("  Discr:             %d\n", Next_Ptr_Glob->Discr);
  small_printf ("        should be:   %d\n", 0);
  small_printf ("  Enum_Comp:         %d\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("  Int_Comp:          %d\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
  small_printf ("        should be:   %d\n", 18);
  small_printf ("  Str_Comp:          %s\n",
                                Next_Ptr_Glob->variant.var_1.Str_Comp);
  small_printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  small_printf ("Int_1_Loc:           %d\n", Int_1_Loc);
  small_printf ("        should be:   %d\n", 5);
  small_printf ("Int_2_Loc:           %d\n", Int_2_Loc);
  small_printf ("        should be:   %d\n", 13);
  small_printf ("Int_3_Loc:           %d\n", Int_3_Loc);
  small_printf ("        should be:   %d\n", 7);
  small_printf ("Enum_Loc:            %d\n", Enum_Loc);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("Str_1_Loc:           %s\n", Str_1_Loc);
  small_printf ("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n");
  small_printf ("Str_2_Loc:           %s\n", Str_2_Loc);
  small_printf ("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n");
  small_printf ("\n");
#endif

  User_Time = End_Time - Begin_Time;
  small_printf ("User time: %d\n", (int)User_Time);
  
  if (User_Time < Too_Small_Time)
  {
    small_printf ("Measured time too small to obtain meaningful results\n");
    small_printf ("Please increase number of runs\n");
    small_printf ("\n");
  }
/*   else */
  {
#if 0
#ifdef TIME
    Microseconds = (User_Time * Mic_secs_Per_Second )
                        /  Number_Of_Runs;
    Dhrystones_Per_Second =  Number_Of_Runs / User_Time;
    Vax_Mips = (Number_Of_Runs*1000) / (1757*User_Time);
#else
    Microseconds = (float) User_Time * Mic_secs_Per_Second 
                        / ((float) HZ * ((float) Number_Of_Runs));
    Dhrystones_Per_Second = ((float) HZ * (float) Number_Of_Runs)
                        / (float) User_Time;
    Vax_Mips = Dhrystones_Per_Second / 1757.0;
#endif
#else
    Microseconds = (1000*User_Time) / Number_Of_Runs;
    Dhrystones_Per_Second =  (Number_Of_Runs*1000) / User_Time;
    Vax_Mips = (Number_Of_Runs*569) / User_Time;
#endif 
    small_printf ("Microseconds for one run through Dhrystone: ");
    small_printf ("%d \n", (int)Microseconds);
    small_printf ("Dhrystones per Second:                      ");
    small_printf ("%d \n", (int)Dhrystones_Per_Second);
    small_printf ("VAX MIPS rating * 1000 = %d \n",(int)Vax_Mips);
    small_printf ("\n");
  }
  
  return 0;
}


Proc_1 (Ptr_Val_Par)
/******************/

REG Rec_Pointer Ptr_Val_Par;
    /* executed once */
{
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;  
                                        /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */
  
  structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob); 
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp 
        = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3 (&Next_Record->Ptr_Comp);
    /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
                        == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
    /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
} /* Proc_1 */


Proc_2 (Int_Par_Ref)
/******************/
    /* executed once */
    /* *Int_Par_Ref == 1, becomes 4 */

One_Fifty   *Int_Par_Ref;
{
  One_Fifty  Int_Loc;  
  Enumeration   Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
      /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */


Proc_3 (Ptr_Ref_Par)
/******************/
    /* executed once */
    /* Ptr_Ref_Par becomes Ptr_Glob */

Rec_Pointer *Ptr_Ref_Par;

{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */


Proc_4 () /* without parameters */
/*******/
    /* executed once */
{
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */


Proc_5 () /* without parameters */
/*******/
    /* executed once */
{
  Ch_1_Glob = 'A';
  Bool_Glob = false;
} /* Proc_5 */


        /* Procedure for the assignment of structures,          */
        /* if the C compiler doesn't support this feature       */
#ifdef  NOSTRUCTASSIGN
memcpy (d, s, l)
register char   *d;
register char   *s;
register int    l;
{
        while (l--) *d++ = *s++;
}
#endif


