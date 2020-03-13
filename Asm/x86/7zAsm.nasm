; 7zAsm.asm -- ASM macros
; 2018-02-03 : Igor Pavlov : Public domain
; 2018-02-03 : P7ZIP       : Public domain
;.intel_syntax noprefix

%define NOT ~
%if __BITS__ == 64
%define x64
%endif

%macro MY_ASM_START 0
  SECTION .text
%endmacro

%macro MY_PROC 2 ; macro name:req, numParams:req
  align 16
  %define proc_numParams %2 ; numParams
    global %1
    global _%1
    %1:
    _%1:
%endmacro

%macro  MY_ENDP 0
  %ifdef x64
    ret
    ; proc_name ENDP
  %else
    %if proc_numParams LT 3
      ret
    %else
      ret ; (proc_numParams - 2) * 4
    %endif
  %endif
  ; proc_name ENDP
%endmacro

%ifdef x64
  REG_SIZE equ 8
  REG_LOGAR_SIZE equ 3
%else
  REG_SIZE equ 4
  REG_LOGAR_SIZE equ 2
%endif

  %define x0_W  AX
  %define x1_W  CX
  %define x2_W  DX
  %define x3_W  BX

  %define x5_W  BP
  %define x6_W  SI
  %define x7_W  DI

  %define x0_L  AL
  %define x1_L  CL
  %define x2_L  DL
  %define x3_L  BL

  %define x0_H  AH
  %define x1_H  CH
  %define x2_H  DH
  %define x3_H  BH

%ifdef x64
  %define x5_L  BPL
  %define x6_L  SIL
  %define x7_L  DIL

  %define r0  RAX
  %define r1  RCX
  %define r2  RDX
  %define r3  RBX
  %define r4  RSP
  %define r5  RBP
  %define r6  RSI
  %define r7  RDI
  %define x8  r8d
  %define x9  r9d
  %define x10  r10d
  %define x11  r11d
  %define x12  r12d
  %define x13  r13d
  %define x14  r14d
  %define x15  r15d
%else
  %define r0  EAX
  %define r1  ECX
  %define r2  EDX
  %define r3  EBX
  %define r4  ESP
  %define r5  EBP
  %define r6  ESI
  %define r7  EDI
%endif

%macro MY_PUSH_4_REGS 0
    push    r3
    push    r5
%ifdef x64
  %ifdef CYGWIN64
    push    r6
    push    r7
  %endif
%else
    push    r6
    push    r7
%endif
%endmacro

%macro MY_POP_4_REGS 0
%ifdef x64
  %ifdef CYGWIN64
    pop     r7
    pop     r6
  %endif
%else
    pop     r7
    pop     r6
%endif
    pop     r5
    pop     r3
%endmacro
