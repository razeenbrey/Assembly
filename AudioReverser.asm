# BRRYAZ002
# MIPS AS 1
# Question 2

.data
in_file_name: .space 75       # store string max len 75
out_file_name: .space 75       # store string max len 75

.text
main:

    # read user string file in
    li $a1, 75              # max length of string
    li $v0, 8               # call read str
    la $a0, in_file_name       # load container
    syscall

    # read user string file out
    li $a1, 75              # max length of string
    li $v0, 8               # call read str
    la $a0, out_file_name       # load container
    syscall

    # read user int - file size
    li $v0, 5               # load syscall to read int
    syscall
    move $s0, $v0           # store int in $s0

    # Remove newline from file
    li $t1, 10
    la $t0, in_file_name

find_newline:
    lb $t2, 0($t0)
    beq $t2, $zero, exit_loop
    beq $t2, $t1, replace
    addi $t0, $t0, 1
    j find_newline

replace:
    sb $zero, 0($t0)        # Replace newline with null terminator

exit_loop:

# Remove newline from file
    li $t1, 10
    la $t0, out_file_name

find_newline1:
    lb $t2, 0($t0)
    beq $t2, $zero, exit_loop1
    beq $t2, $t1, replace1
    addi $t0, $t0, 1
    j find_newline1

replace1:
    sb $zero, 0($t0)        # Replace newline with null terminator

exit_loop1:

# open input file as read (0)
    li $v0, 13              # Syscall -> open file
    li $a1, 0               # load immediate 0 to flag $a1 | flag -> read(0) / write(1)
    la $a0, in_file_name    # Get file name
    syscall
    move $s5, $v0           # save file descriptor as $s5

# open output file as write
    li $v0, 13              # Syscall -> open file
    la $a0, out_file_name   # Get file name
    li $a1, 0x2             # flags -> read and write
    li $a2, 0x1B6           # mode ->  read-write
    syscall
    move $s2, $v0           # save file descrptr as $s2

# setup heap for in and out files
    # infile
    li $v0, 9               # Syscall -> setup heap
    move $a0, $s0            # set heap size to file size ($s0)
    syscall
    move $s1, $v0

    # outfile
    li $v0, 9               # Syscall -> setup heap
    move $a0, $s0             # set heap size to file size ($s0)
    syscall
    move $s4, $v0

    # read file
    li $v0, 14              # Syscall -> Read file
    move $a0, $s5           # fetch file descriptor to place in $a0
    move $a1, $s1           # address to store file data
    move $a2, $s0           # max read characters = filesize
    syscall

copy_header:
    move $t3, $s1                          # $t3 -> start of header
    addi $t3, $t3, 44                                       # Move $t3 44 bytes to end header
    move $t2, $s1                                          # $t2 -> current header location
    move $t1, $s4                                                       # $t1 -> output header
copy_h_strt:
    beq $t3, $t2, end_copy                                                # If header copied ->  end_copy
    lb $t0, ($t2)                                                      # Load from input buffer
    sb $t0, ($t1)                                                       # Store in output
    addi $t2, $t2, 1                                                # input cursor ++
    addi $t1, $t1, 1                                                      # output cursor ++
    j copy_h_strt                                                         

end_copy:
    addi $t3, $t3, -2             # Move $t0 -> last audio sample in input
    add $t2, $s1, $s0                        # $t2 -> end of file
    addi $t2, $t2, -2                                                     # Move $t2 -> last halfwrd sample

copy_strt:
    beq $t3, $t2, w_file                                                  # If all copied, -> w_file
    lh $t4, ($t2)                             # Load halfwrd sample from the input
    sh $t4, ($t1)                                                         # Store halfwrd sample in output
    addi $t2, $t2, -2                  # Move to previous sample in the input 
    addi $t1, $t1, 2                                                      # Move to the next sample in the output
    j copy_strt                              # Repeat the loop

w_file:
    li $v0, 15                                                       # Syscall -> write to a file
    move $a0, $s2                                                         # Move  output file descriptor to $a0
    move $a1, $s4                                                     # Move  output buffer address to $a1
    move $a2, $s0                                                    # Move file size to $a2
    syscall                                                               #  write the reversed data to the file

close:
    li $v0, 16                                                            # Syscall -> close a file
    move $a0, $s2                                                   # Move file descriptor to $a0
    syscall                                                               
    li $v0, 16                                                            # Syscall to close a file
    move $a0, $s5                                                     # Move the input file descriptor to $a0
    syscall

    j exit
    # Terminate program
    exit:
    li $v0, 10
    syscall