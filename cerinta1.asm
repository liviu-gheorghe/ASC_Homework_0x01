.data

n: .space 0x04
m: .space 0x04
sol: .space 0x168
dimFP: .space 0x04
dimSol: .space 0x04
fixedPoints: .space 0x168
x: .space 0x04
nrApNr: .space 0x04
lastNrPoz: .space 0x04
currentLevel: .space 0x04
cpEcx: .space 0x04

formatSMN: .asciz "%d %d"
formatSD: .asciz "%d"
formatPD: .asciz "%d "
fNL: .asciz "\n"
fNE: .asciz "-1\n"

.text

.global main


checkAppear:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 0x08(%ebp), %eax
    movl %eax, currentLevel
    movl $0x0, nrApNr 
    movl m, %ebx
    movl %ebx, lastNrPoz
    notl lastNrPoz
    subl $0x01, lastNrPoz

    xorl %ecx, %ecx

    et_forCheckAppear:
    cmpl currentLevel, %ecx
    je et_ForCheckAppearEnd

    movl (%esi, %ecx, 0x04), %eax
    movl currentLevel, %ebx
    cmpl %eax, (%esi, %ebx, 0x04)
    je updateUsage
    jne et_ForCheckAppearCont
    updateUsage:
    addl $0x01, nrApNr
    movl %ecx, lastNrPoz

    et_ForCheckAppearCont:
    addl $0x01, %ecx
    jmp et_forCheckAppear

    et_ForCheckAppearEnd:
    
    movl nrApNr, %eax
    cmpl $0x02, %eax
    jg checkAppear_NOTOK

    movl currentLevel, %eax
    subl lastNrPoz, %eax

    cmpl m, %eax
    jg checkAppear_OK
    jle checkAppear_NOTOK  

    checkAppear_NOTOK:
    movl $0x00, %eax
    jmp checkAppear_Ret

    checkAppear_OK:
    movl $0x01, %eax
    jmp checkAppear_Ret

    checkAppear_Ret:
    popl %ebx
    popl %ebp
    ret


checkFixedPoint:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    movl 0x08(%ebp), %ebx
    #fixedPoints[%ebx] == 0
    movl (%edi, %ebx, 0x04), %eax
    cmpl $0x00, %eax
    je checkFixedPoint_OK
    jne checkFixedPoint_Exec
    jmp checkFixedPoint_Ret

    checkFixedPoint_Exec:
    movl (%edi, %ebx, 0x04), %eax
    cmpl  (%esi, %ebx, 0x04), %eax
    je checkFixedPoint_OK_2
    jne checkFixedPoint_NOTOK

    checkFixedPoint_OK:
    movl $0x01, %eax
    jmp checkFixedPoint_Ret

    checkFixedPoint_OK_2:
    movl $0x02, %eax
    jmp checkFixedPoint_Ret

    checkFixedPoint_NOTOK:
    movl $0x00, %eax
    jmp checkFixedPoint_Ret

    checkFixedPoint_Ret:
    popl %ebx
    popl %ebp
    ret

bkt:
    pushl %ebp
    movl %esp, %ebp    
    pushl %ebx
    movl 0x08(%ebp), %edx

    movl $0x01, %ecx
    et_ForBkt:
    movl %ecx, (%esi, %edx, 0x04)
    pushl %edx
    call checkFixedPoint
    popl %edx
    cmpl $0x00, %eax
    je et_ForBktEnd
    cmp $0x01, %eax
    je et_ForBktCont1
    cmp $0x02, %eax
    je et_ForBktCont1

    et_ForBktCont1:
    pushl %ecx
    pushl %edx
    call checkAppear
    popl %edx
    popl %ecx 
    cmpl $0x01, %eax
    jne et_ForBktEnd

    et_ForBktCont2:
    movl dimSol, %eax
    subl $0x01, %eax

    cmpl %eax, %edx
    je et_AfSol
    pushl %ecx
    pushl %edx
    movl %edx, %eax
    addl $0x01, %eax
    pushl %eax
    call bkt
    popl %ebx
    popl %edx
    popl %ecx
  
    jmp et_ForBktEnd

    et_ForBktEnd:
    addl $0x01, %ecx 
    cmpl n, %ecx
    jle et_ForBkt
    popl %ebx
    popl %ebp
    ret

main:
leal fixedPoints, %edi
leal sol, %esi

pushl $m
pushl $n
pushl $formatSMN
call scanf
popl %ebx
popl %ebx
popl %ebx

movl n, %eax
movl %eax, dimFP
sall %eax
addl %eax, dimFP
movl dimFP, %eax
movl %eax, dimSol

xorl %ecx, %ecx

et_ForReadFPArr:
    pushl %ecx
    pushl $x
    pushl $formatSD
    call scanf
    popl %ebx
    popl %ebx
    popl %ecx

    movl x, %eax
    movl %eax, (%edi, %ecx, 0x04)
    addl $0x01, %ecx
    cmpl %ecx, dimFP
    jne et_ForReadFPArr

   pushl $0x00
   call bkt
   popl %ebx

   pushl $fNE
   call printf
   popl %ebx

et_exit:
    movl $0x01, %eax
    xorl %ebx, %ebx
    int $0x80

et_AfSol:
    xorl %ecx, %ecx
    et_AfSolFor:
        pushl %ecx
        cmpl dimSol, %ecx
        jge et_AfSolEnd
        
        movl (%esi, %ecx, 0x04), %eax
        pushl %eax
        pushl $formatPD
        call printf
        popl %ebx
        popl %ebx
        popl %ecx
        addl $0x01, %ecx
        jmp et_AfSolFor


et_AfSolEnd:
    pushl $fNL
    call printf
    popl %ebx

    pushl $0x00
    call fflush
    popl %ebx 
    jmp et_exit

