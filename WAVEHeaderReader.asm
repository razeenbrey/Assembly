# BRRYAZ002
# MIPS AS 1
# Question 1

.data
file_name: .space 75       # store string max len 75
prompt_str1: .asciiz "Enter a wave file name:\n"            # Prompt 1
prompt_str2: .asciiz "Enter the file size (in bytes):\n"
disp_str1:  .asciiz "Information about the wave file:\n"
disp_str2: .asciiz  "================================\n"
s1: .asciiz "Number of channels: "
s2: .asciiz "\nSample rate: "
s3: .asciiz "\nByte rate: "
s4: .asciiz "\nBits per sample: "

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

    # read user int
    li $v0, 5               # load syscall to read int
    syscall
    move $t0, $v0           # store int in $t0

    # remove newline from file name
    #li $t1, '\n'
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
    addi $sp, $sp, -44      # allocate 44 bytes on stack

    # read file
    li $v0, 14              # Syscall -> Read file
    move $a0, $s0           # fetch file descriptor to place in $a0
    move $a1, $sp           # load stack pointer to hold file
    li $a2, 44              # max read characters
    syscall

    # Output
    li $v0, 4
    la $a0, disp_str1
    syscall

    li $v0, 4
    la $a0, disp_str2
    syscall

    # Ch no
    li $v0, 4
    la $a0, s1
    syscall

    ## print chnl
    lh $t3, 22($sp)
    li $v0, 1
    move $a0, $t3
    syscall

    # Smpl rate
    li $v0, 4
    la $a0, s2
    syscall

    ## print smpl rate
    lw $t3, 24($sp)
    li $v0, 1
    move $a0, $t3
    syscall

    # Byte rate
    li $v0, 4
    la $a0, s3
    syscall

    ## print byte rate
    lw $t3, 28($sp)
    li $v0, 1
    move $a0, $t3
    syscall

    # Bytes per sample
    li $v0, 4
    la $a0, s4
    syscall

    ## print bytes per smpl
    lh $t3, 34($sp)
    li $v0, 1
    move $a0, $t3
    syscall

    # deallocate space on stack
    addi $sp, $sp, 44       # deallocate 44 bytes from stack
    j exit
    # Terminate program
    exit:
    li $v0, 10
    syscall