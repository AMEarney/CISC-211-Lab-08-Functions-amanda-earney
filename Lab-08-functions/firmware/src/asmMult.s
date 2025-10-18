/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Amanda Earney"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,a_Sign,b_Sign,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    push {r4-r11, LR} /* store state of program according to calling convention */
    
    MOV r3, r0 /* puts the packed value into r3 to unpack the value of A */
    ASR r3, r3, 16 /* shifts the A value into the LSBs with sign extension */
    
    MOV r4, r0 /* puts the packed value into r4 to unpack the value of B */
    LSL r4, r4, 16 /* shifts the LSBs into the MSBs to discard A's bits from B */
    ASR r4, r4, 16 /* shifts the B value into the LSBs with sign extension */
    
    STR r3, [r1] /* puts the A value into the address specified by r1 */
    STR r4, [r2] /* puts the B value into the address specified by r2 */
    
    pop {r4-r11, LR} /* restore state of program */
    MOV PC, LR /* return to caller */
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */    
asmAbs:  

    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push {r4-r11, LR} /* store state of program according to calling convention */
    
    TST r0, 32768 /* tests the value of the sign bit */
    BEQ positiveValue
    
    LDR r4, =1
    STR r4, [r2] /* stores the correct sign bit into memory */
    NEG r5, r0 /* negates the input value and stores it in r5 */
    STR r5, [r1] /* stores the abs value into memory */
    MOV r0, r5 /* puts the abs value into r0 to return */
    B endAbs
    
positiveValue:
    LDR r4, =0 
    STR r4, [r2] /* stores the correct sign bit into memory */
    STR r0, [r1] /* stores the abs value into memory */
    
endAbs:
    pop {r4-r11, LR} /* restore state of program */
    MOV PC, LR /* return to caller */
    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */ 
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    push {r4-r11, LR} /* store state of program according to calling convention */
    
    LDR r4, =0 /* accumulated product will be stored in r4 */
    
loop: 
    CBZ r1, endLoop /* ends the loop when the multiplier is 0 */
    TST r1, 1 /* checks LSB of multiplier */
    ADDNE r4, r4, r0 /* if the LSB is 1, adds the multiplicand to the product */
    LSL r0, r0, 1 /* shifts the multiplicand to the left 1 bit */
    LSR r1, r1, 1 /* shifts the multiplier to the right 1 bit */
    B loop
    
endLoop:
    MOV r0, r4 /* puts the product into r0 to return it */
    
    pop {r4-r11, LR} /* restore state of program */
    MOV PC, LR /* return to caller */
    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/

   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    push {r4-r11, LR} /* store state of program according to calling convention */
    
    EOR r3, r1, r2 /* puts 1 in r3 if product should be neg, 0 if should be pos */
    CBZ r3, endFixSign /* if already positive, should return input */
    
    NEG r0, r0 /* negates the input and puts it back into r0 */
    
endFixSign:
    pop {r4-r11, LR} /* restore state of program */
    MOV PC, LR /* return to caller */
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */  
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    push {r4-r11, LR} /* store state of program according to calling convention */
    
    LDR r2, =0 /* resets all variables to 0 */
    LDR r3, =rng_Error
    LDR r4, =a_Sign
    LDR r5, =b_Sign
    LDR r6, =prod_Is_Neg
    LDR r7, =a_Abs
    LDR r8, =b_Abs
    LDR r9, =init_Product
    LDR r10, =final_Product
    STR r2, [r3]
    STR r2, [r4]
    STR r2, [r5]
    STR r2, [r6]
    STR r2, [r7]
    STR r2, [r8]
    STR r2, [r9]
    STR r2, [r10]
    
    /* Step 1:
     * call asmUnpack. Have it store the output values in a_Multiplicand
     * and b_Multiplier.
     */
    LDR r1, =a_Multiplicand /* prepares inputs */
    LDR r2, =b_Multiplier
    BL asmUnpack /* calls function */

     /* Step 2a:
      * call asmAbs for the multiplicand (a). Have it store the absolute value
      * in a_Abs, and the sign in a_Sign.
      */
    LDR r1, =a_Multiplicand /* prepares inputs */
    LDR r0, [r1] 
    LDR r1, =a_Abs
    LDR r2, =a_Sign
    BL asmAbs /* calls function */
    
     /* Step 2b:
      * call asmAbs for the multiplier (b). Have it store the absolute value
      * in b_Abs, and the sign in b_Sign.
      */
    LDR r1, =b_Multiplier /* prepares inputs */
    LDR r0, [r1] 
    LDR r1, =b_Abs
    LDR r2, =b_Sign
    BL asmAbs /* calls function */

    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * In this function (asmMain), store the output value  
     * returned asmMult in r0 to mem location init_Product.
     */
    LDR r2, =a_Abs /* prepares inputs */
    LDR r0, [r2]
    LDR r2, =b_Abs
    LDR r1, [r2]
    BL asmMult /* calls function */
    
    LDR r2, =init_Product /* stores the initial product found by asmMult */
    STR r0, [r2] 

    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. Store the value returned in r0 to mem location 
     * final_Product.
     */
    LDR r3, =a_Sign /* prepares inputs */
    LDR r1, [r3] 
    LDR r4, =b_Sign
    LDR r2, [r4] 
    BL asmFixSign /* calls function */
    
    LDR r3, =final_Product 
    STR r0, [r3] /* stores the final product returned by asmFixSign */

     /* Step 5:
      * END! Return to caller. Make sure of the following:
      * 1) Stack has been correctly managed.
      * 2) the final answer is stored in r0, so that the C call 
      *    can access it.
      */
    pop {r4-r11, LR} /* restore state of program */
    MOV PC, LR /* return to caller */
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
