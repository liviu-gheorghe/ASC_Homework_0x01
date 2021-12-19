.data

matrix: .space 0x168
x: .space 0x04
filePtr: .space 0x04
formatRI: .asciz "%1d"
adrEl: .space 0x04
row: .space 0x04
col: .space 0x04
idxCurent: .space 0x04
boxStartRow: .space 0x04
boxStartCol: .space 0x04
cpEcx: .space 0x04
cpEbx: .space 0x04

formatInputFN: .asciz "cerinta2.in"
formatPD: .asciz "%d "
formatReadMode: .asciz "r"
fNE: .asciz "-1\n"
fNL: .asciz "\n"


.text

.global main

UsedInBox:
pushl %ebp
movl %esp, %ebp
pushl %ebx

#Compute row - row % 3 in boxStartRow

xorl %edx, %edx
movl row, %eax
movl %eax, boxStartRow
movl $0x03, %ebx
idivl %ebx
subl %edx, boxStartRow


#Compute col - col % 3 in boxStartCol

xorl %edx, %edx
movl col, %eax
movl %eax, boxStartCol
movl $0x03, %ebx
idivl %ebx
subl %edx, boxStartCol



#Move parameter from stack into edx

movl 0x08(%ebp), %edx

#Use ebx as i and ecx as j to loop through the submatrix 
xorl %ebx, %ebx
et_ForUIB_I:
    cmpl $0x03, %ebx
    je et_ForUIB_IEND
    movl %ebx, cpEbx
    xorl %ecx, %ecx

    #Save ebx on the stack so we can use it in computations inside the et_ForUIB_J label

    et_ForUIB_J:
        cmpl $0x03, %ecx
        je et_ForUIB_JEND

        movl %ecx, cpEcx
        movl %ebx, cpEbx


        #We must get sol[ebx + boxStartRow][ecx + boxStartCol]

        addl boxStartRow, %ebx

        movl %ebx, %eax
        movl $0x09, %ebx 
        imull %ebx
        et_78:addl %ecx, %eax
        addl boxStartCol, %eax
        movl 0x08(%ebp), %edx
        et_81:cmpl (%edi, %eax, 0x04), %edx
        je UsedInBox_NOTOK

        movl cpEcx, %ecx
        movl cpEbx, %ebx

        addl $0x01, %ecx
        jmp et_ForUIB_J
        et_ForUIB_JEND:
            jmp et_ForUIB_ICont

    et_ForUIB_ICont:
    movl cpEbx, %ebx
    addl $0x01, %ebx
    jmp et_ForUIB_I

et_ForUIB_IEND:
    jmp UsedInBox_OK

#TODO Implement logic for function and delete the instruction form next line
#jmp UsedInBox_OK

UsedInBox_OK:
movl $0x00, %eax
jmp UsedInBox_Ret

UsedInBox_NOTOK:
movl $0x01, %eax
jmp UsedInBox_Ret

UsedInBox_Ret:
popl %ebx
popl %ebp
ret


UsedInCol:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 0x08(%ebp), %edx
    xorl %ecx, %ecx


    UsedInCol_For:
        cmpl $0x09, %ecx
        je UsedInCol_ForEnd

        #In eax trebuie sa am sol[row][col], dar eu ma plimb cu row de la 0 la 8
        #row-ul curent este ecx
        movl %ecx, %eax
        movl %eax, %ebx
        sall $0x03, %eax
        addl %ebx, %eax
        addl col, %eax

        cmpl (%edi, %eax, 0x04), %edx
        je UsedInCol_NOTOK

        addl $0x01, %ecx
        jmp UsedInCol_For
    UsedInCol_ForEnd:
        jmp UsedInCol_OK

    UsedInCol_OK:
        movl $0x00, %eax
        jmp UsedInCol_Ret

    UsedInCol_NOTOK:
        movl $0x01, %eax
        jmp UsedInCol_Ret

    UsedInCol_Ret:
        popl %ebx
        popl %ebp
        ret

UsedInRow:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 0x08(%ebp), %edx

    xorl %ecx, %ecx

    #Stochez in eax valoarea 9 * row
    movl row, %eax
    movl %eax, %ebx
    sall $0x03, %eax
    addl %ebx, %eax

    UsedInRow_For:
        cmpl $0x09, %ecx
        je UsedInRow_ForEnd

        cmpl (%edi, %eax, 0x04), %edx
        je UsedInRow_NOTOK

        addl $0x01, %eax
        addl $0x01, %ecx
        jmp UsedInRow_For
    UsedInRow_ForEnd:
        jmp UsedInRow_OK


    UsedInRow_OK:
        movl $0x00, %eax
        jmp UsedInRow_Ret

    UsedInRow_NOTOK:
        movl $0x01, %eax
        jmp UsedInRow_Ret

    UsedInRow_Ret:
        popl %ebx
        popl %ebp
        ret

valid:
pushl %ebp
movl %esp, %ebp


#ecx e elementul curent pe care trebuie sa il verificam daca e valid
movl 0x08(%ebp), %ecx

pushl %ecx
call UsedInRow
popl %ecx

cmpl $0x01, %eax
je valid_NOTOK


pushl %ecx
call UsedInCol
popl %ecx

cmpl $0x01, %eax
je valid_NOTOK

pushl %ecx
call UsedInBox
popl %ecx

cmpl $0x01, %eax
je valid_NOTOK

movl row, %eax
movl %eax, %ebx
sall $0x03, %eax
addl %ebx, %eax
addl col, %eax

xorl %ebx, %ebx
cmpl (%edi, %eax, 0x04), %ebx
jne valid_NOTOK
je valid_OK


valid_NOTOK:
movl $0x00, %eax
jmp valid_Ret

valid_OK:
movl $0x01, %eax
jmp valid_Ret

valid_Ret:
popl %ebp
ret

findFreeCell:

pushl %ebp
pushl %ebx
movl %esp, %ebp

xorl %ecx, %ecx
findFreeCell_For:

movl (%edi, %ecx, 0x04), %ebx
cmpl $0x00, %ebx
je findFreeCell_OK


addl $0x01, %ecx
cmpl $0x51, %ecx
je findFreeCell_NOTOK
jne findFreeCell_For


findFreeCell_OK:
    #trebuie calculate row si col
    # row  = catul impartirii lui ecx la 9
    #col = restul impartirii lui ecx la 9

    xorl %edx, %edx
    movl %ecx, %eax
    movl $0x09, %ebx
    idivl %ebx
    movl %eax, row
    movl %edx, col
    movl $0x01, %eax
    jmp findFreeCell_ForEnd


findFreeCell_NOTOK:
    movl $0x00, %eax
    jmp findFreeCell_ForEnd

findFreeCell_ForEnd:
popl %ebx
popl %ebp
ret

bkt:
    pushl %ebp
    movl %esp, %ebp    
    pushl %ebx

    call findFreeCell

    cmpl $0x00, %eax
    je et_WriteMatrix


    et_323:

    movl $0x01, %ecx

    et_ForBkt:

    pushl %ecx
    call valid
    popl %ecx


    cmpl $0x00, %eax
    je et_ForBktEnd

    et_102:#formula de acces pt matrix[row][col] este row * 9 + col
    movl row, %eax
    movl %eax, %ebx
    sall $0x03, %eax
    addl %ebx, %eax
    addl col, %eax

    movl %ecx, (%edi, %eax, 0x04)


    pushl col
    pushl row
    pushl %eax
    pushl %ecx
    call bkt
    popl %ecx
    popl %eax
    popl row
    popl col

    movl $0x00, (%edi, %eax, 0x04)
  
    jmp et_ForBktEnd

    et_ForBktEnd:
    addl $0x01, %ecx 
    cmpl $0x09, %ecx
    jle et_ForBkt
    popl %ebx
    popl %ebp
    ret


main:
leal matrix, %edi


et_ReadMatrix:

    pushl $formatReadMode
    pushl $formatInputFN
    call fopen
    pushl %ebx
    pushl %ebx
    movl %eax, filePtr


xorl %ecx, %ecx

et_ForReadMatrix:

    movl %ecx, %eax
    sall $0x02, %eax
    addl %edi, %eax
    movl %eax, adrEl
    pushl %ecx
    pushl adrEl
    pushl $formatRI
    pushl filePtr
    call fscanf
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ecx

    addl $0x01, %ecx
    cmpl $0x51, %ecx
    jne et_ForReadMatrix

   call bkt

   pushl $fNE
   call printf
   popl %ebx

et_exit:
    movl $0x01, %eax
    xorl %ebx, %ebx
    int $0x80

et_WriteMatrix:

    xorl %ecx, %ecx

    et_WriteMatrix_For:

    movl (%edi, %ecx, 0x04), %eax

    pushl %ecx
    pushl %eax
    pushl $formatPD
    call printf
    popl %ebx
    popl %ebx
    popl %ecx

    xorl %edx, %edx
    movl %ecx, %eax
    incl %eax
    movl $0x09, %ebx
    idivl %ebx
    cmpl $0x00, %edx
    je et_PrintNewline

    et_WriteMatrix_Cont:
    addl $0x01, %ecx
    cmpl $0x51, %ecx
    je et_WriteMatrix_ForEnd
    jne et_WriteMatrix_For
    et_WriteMatrix_ForEnd:

    pushl $0x00
    call fflush
    popl %ebx

    jmp et_exit


et_PrintNewline:
    pushl %ecx
    pushl $fNL 
    call printf
    popl %ebx
    popl %ecx
    jmp et_WriteMatrix_Cont
     

