# BRRYAZ002
# MIPS AS 1
# Question 2

.data
file_name: .space 75       # store string max len 75
#file_name: .asciiz "C:\Users\razee\b.wav"
prompt_str1: .asciiz "Enter a wave file name:\n"            # Prompt 1
prompt_str2: .asciiz "Enter the file size (in bytes):\n"
disp_str1:  .asciiz "Information about the wave file:\n"
disp_str2: .asciiz  "================================\n"
s1: .asciiz "Number of channels: "
s2: .asciiz "Maximum amplitude: "
s3: .asciiz "\nMinimum amplitude: "
s4: .asciiz "\nBits per sample: "
nlin: .asciiz "\n"

.text
main:

    # print prompt1
    li $v0, 4               # load immediate $v0 print str
    la $a0, prompt_str1     # load prompt 1
    syscall

    # read user string
    li $a1, 75              # max length of string
    li $v0, 8               # call read str
    la $a0, file_name       # load container
    syscall
    
    # print prompt 2
    li $v0, 4               # print prompt
    la $a0, prompt_str2     # load prompt 2
    syscall

    # read user int - file size
    li $v0, 5               # load syscall to read int
    syscall
    move $s1, $v0           # store int in $s1

    ###############do not uncomment
    # # calculate data section of audio file
    # li $t1, 44              # $t1 = 44 (size of metadata)
    # sub $t2, $t0, $t1       # remove metadata from size total, store in $t2
    # move $s1, $t2           # store in $s1

    # # remove newline from file name
    #li $t1, '\n'
    ###############do not uncomment

        li $t1, 10
    la $t0, file_name

 find_newline:
    lb $t2, 0($t0)
    beq $t2, $zero, exit_loop
    beq $t2, $t1, replace
    addi $t0, $t0, 1
    j find_newline

replace:
    sb $zero, 0($t0)        # Replace newline with null terminator

exit_loop:

    # open file
    li $v0, 13              # Syscall -> open file
    li $a1, 0               # load immediate 0 to flag $a1 | flag -> read(0) / write(1)
    la $a0, file_name       # Get file name
    syscall
    move $s0, $v0           # save file descriptor as $s0

    # allocate space on stack for file contents
    subu $sp, $sp, $s1      # allocate 44 bytes on stack

    # read file
    li $v0, 14              # Syscall -> Read file
    move $a0, $s0           # fetch file descriptor to place in $a0
    move $a1, $sp           # load stack pointer to hold file
    move $a2, $s1           # max read characters
    syscall

    addi $sp, $sp, 44

    # compare
    subu $t0, $s1, 44       # counter
    lh $t2, 0($sp)          # t2 min
    move $t3, $t2           # t3 max
    li $t4, 0

go:
    beq $t0, $t4, exit1
    lh $t1, 0($sp)

    # test stuff
    # li $v0, 1
    # move $a0, $t1
    # syscall
    # li $v0, 4
    # la $a0, nlin
    # syscall

    blt	$t1, $t2, chng_min	# if $t0 < $t1 then goto target
    bgt	$t1, $t3, chng_max	# if $t0 > $t1 then goto target
    addi $t0, $t0, -2			# $t0 = $t1 - 0
    addi $sp, $sp, 2
    j go

chng_max:
    move $t3, $t1
    addi $t0, $t0, -2			# $t0 = $t1 - 0
    addi $sp, $sp, 2
    j go
chng_min:
    move $t2, $t1
    addi $t0, $t0, -2			# $t0 = $t1 - 0
    addi $sp, $sp, 2
    j go
exit1:

    # Output
    li $v0, 4
    la $a0, disp_str1
    syscall

    li $v0, 4
    la $a0, disp_str2
    syscall

    # print max
    li $v0, 4
    la $a0, s2
    syscall
    li $v0, 1
    move $a0, $t3
    syscall

    # print min
    li $v0, 4
    la $a0, s3
    syscall
    li $v0, 1
    move $a0, $t2
    syscall

    ## print test
    # lh $t3, 40($sp)
    # li $v0, 1
    # move $a0, $t3
    # syscall

    # deallocate space on stack
    add $sp, $sp, $s1       # deallocate 44 bytes from stack
    j exit
    # Terminate program
    exit:
    li $v0, 10
    syscall