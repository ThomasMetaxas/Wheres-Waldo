.data
displayBuffer:  .space 0x40000 # space for 512x256 bitmap display
.space 48 #Adding 48 bits of padding, ie 3 cache blocks
errorBuffer:    .space 0x40000 # space to store match function
.space 48 #Adding 48 bits of padding, ie 3 cache blocks
templateBuffer: .space 0x100   # space for 8x8 template
imageFileName:    .asciiz "pxlcon512x256cropgs.raw"
templateFileName: .asciiz "template8x8gsLRtest.raw"
# struct bufferInfo { int *buffer, int width, int height, char* filename }
imageBufferInfo:    .word displayBuffer  512 128  imageFileName
errorBufferInfo:    .word errorBuffer    512 128  0
templateBufferInfo: .word templateBuffer 8   8    templateFileName

.text
main:	la $a0, imageBufferInfo
	jal loadImage
	la $a0, templateBufferInfo
	jal loadImage
	la $a0, imageBufferInfo
	la $a1, templateBufferInfo
	la $a2, errorBufferInfo
	jal matchTemplateFast        # MATCHING DONE HERE
	la $a0, errorBufferInfo
	jal findBest
	la $a0, imageBufferInfo
	move $a1, $v0
	jal highlight
	la $a0, errorBufferInfo	
	jal processError
	
	li $v0, 10		# exit
	syscall
	

##########################################################
# matchTemplate( bufferInfo imageBufferInfo, bufferInfo templateBufferInfo, bufferInfo errorBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
matchTemplate:	
	
	subi $sp, $sp, 12
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $s6, 0($sp) #Save $s4, $s5, $s6 on the stack in case they are used by the parent function
	lw $s4, 4($a0) #Image Width
	lw $s5, 8($a0) #Image Height
	subi $s4, $s4, 8 #w -= 8
	subi $s5, $s5, 8 #h -= 8 Because loop iterates to w-8 & h-8
	li $s6, 8 #Template Width/Height "The provided functions make the assumption that the template is always 8 by 8"
	
	move $t1, $zero #int y = 0
	imageLoopY: #for (int y = 0; y <= height - 8; y++)
	bgt $t1, $s5, loopEnd #y <= height - 8
	
	move $t0, $zero #int x = 0
	j imageLoopX
	#End of iteration
	cImageLoopY: #c for continue the loop
	addi $t1, $t1, 1 #y++
	j imageLoopY
		imageLoopX: #for (int x = 0; x <= width - 8; x++)
		bgt $t0, $s4, cImageLoopY #x <= width - 8
		
		move $t3, $zero #int j = 0
		j templateLoopJ
		#End of iteration
		cImageLoopX: #c for continue the loop
		addi $t0, $t0, 1 #x++
		j imageLoopX
			templateLoopJ: #for (int j = 0; j < 8; j++)
			beq $t3, $s6, cImageLoopX #j < 8
			
			move $t2, $zero #int i = 0
			j templateLoopI
			
			#End of iteration
			cTemplateLoopJ: #c for continue the loop
			addi $t3, $t3, 1 #j++
			j templateLoopJ
				templateLoopI: #for (int i = 0; i < 8; i++)
				beq $t2, $s6, cTemplateLoopJ #i < 8
				
				lw $t5, 0($a0) #For image
				la $t5, ($t5)
				add $t6, $t0, $t2 #x+i
				add $t7, $t1, $t3 #y+j
				addi $t4, $s4, 8 #Add 8 to (w-8) to get w
				mul $t4, $t4, $t7 #w*row
				add $t4, $t4, $t6 #w*row + col
				li $t7, 4
				mul $t4, $t4, $t7 #4(w*row + col)
				add $t5, $t5, $t4
				lbu $t6, ($t5) #I(x+i)(y+j)
				lw $t5, 0($a1) #For template
				la $t5, ($t5)
				mul $t4, $s6, $t3 #w*row
				add $t4, $t4, $t2 #w*row + col
				li $t7, 4
				mul $t4, $t4, $t7 #4(w*row + col)
				add $t5, $t5, $t4
				lbu $t7, ($t5) #T(i)(j)
				sub $t4, $t6, $t7 #(I(x+i)(y+j) - T(i)(j))
				abs $t4, $t4 #|(I(x+i)(y+j) - T(i)(j))|
				lw $t5, 0($a2) #For error buffer
				la $t5, ($t5)
				addi $t6, $s4, 8 #Add 8 to (w-8) to get w
				mul $t6, $t6, $t1 #w*row
				add $t6, $t6, $t0 #w*row + col
				li $t7, 4
				mul $t6, $t6, $t7 #4(w*row + col)
				add $t5, $t5, $t6
				lw $t6, ($t5)
				add $t4, $t4, $t6 #S(x)(y) += |(I(x+i)(y+j) - T(i)(j))|
				sw $t4, ($t5)
				
				#End of iteration
				addi $t2, $t2, 1 #i++
				j templateLoopI #Repeat loop
	
	loopEnd:
	lw $s4, 8($sp)
	lw $s5, 4($sp)
	lw $s6, 0($sp) #Load $s4, $s5, $s6 from the stack for potential use by the parent function
	addi $sp, $sp, 12
	jr $ra	
	
##########################################################
# matchTemplateFast( bufferInfo imageBufferInfo, bufferInfo templateBufferInfo, bufferInfo errorBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
matchTemplateFast:	
	
	# TODO: write this function!
	addi $sp, $sp, -32
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	
	lw $s4, 4($a0) #Image Width
	lw $s5, 8($a0) #Image Height
	addi $s4, $s4, -8 #w -= 8
	addi $s5, $s5, -8 #h -= 8 Because loop iterates to w-8 & h-8
	
	lw $t5, 0($a1) #Template
	la $a1, ($t5)
	
	lw $t6, 0($a2) #For error
	la $a2, ($t6)
	
	lw $t5, 0($a0) #For image
	la $a0, ($t5)
	
	move $t2, $zero #int j = 0
	loopJ: #for (int j = 0; j < 8; j++)
	beq $t2, 8, loopEndFast #x < 8
	#Code here
	
	lbu $t3, 0($a1) #t0
	lbu $s0, 4($a1) #t1
	lbu $s1, 8($a1) #t2
	lbu $s2, 12($a1) #t3
	lbu $s3, 16($a1) #t4
	lbu $s6, 20($a1) #t5
	lbu $s7, 24($a1) #t6
	lbu $t7, 28($a1) #t7

	move $t6, $a2 #Reset error buffer base address
	move $t5, $a0
	
	move $t1, $zero #int y = 0
	j loopY
	#End of iteration
	cLoopJ: #c for continue the loop
	addi $a0, $a0, 2048
	addi $a1, $a1, 32
	addi $t2, $t2, 1 #j++
	j loopJ
		loopY: #for (int y = 0; y <= height - 8; y++)
		bgt $t1, $s5, cLoopJ #y <= height - 8
		#Code here
	
		move $t0, $zero #int x = 0
		j loopX
		#End of iteration
		cLoopY:
		addi $t5, $t5, 28
		addi $t6, $t6, 28  # Increase offset
		addi $t1, $t1, 1 #y++
		j loopY
			loopX: #for (int x = 0; x <= width - 8; x++)
			bgt $t0, $s4, cLoopY
			#Code here
			
			lw $t9, ($t6) #SAD[x,y]
			#t0
			lbu $t4, 0($t5) #I[x][y]
			sub $t4, $t4, $t3 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			#t1
			lbu $t4, 4($t5) #I[x][y]
			sub $t4, $t4, $s0 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			#t2
			lbu $t4, 8($t5) #I[x][y]
			sub $t4, $t4, $s1 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			#t3
			lbu $t4, 12($t5) #I[x][y]
			sub $t4, $t4, $s2 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			#t4
			lbu $t4, 16($t5) #I[x][y]
			sub $t4, $t4, $s3 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			#t5
			lbu $t4, 20($t5) #I[x][y]
			sub $t4, $t4, $s6 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			#t6
			lbu $t4, 24($t5) #I[x][y]
			sub $t4, $t4, $s7 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			#t7
			lbu $t4, 28($t5) #I[x][y]
			sub $t4, $t4, $t7 #I[x][y] - t
			abs $t4, $t4 #|I[x][y] - t|
			add $t9, $t4, $t9 #SAD[x,y] += abs
			
			sw $t9, ($t6)
			
			
			addi $t5, $t5, 4 #Shift offset
			addi $t6, $t6, 4 #Increase offset
			#End of iteration
			addi $t0, $t0, 1 #x++
			j loopX
	
	
	loopEndFast:
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	addi $sp, $sp, 32
	jr $ra	
		
###############################################################
# loadImage( bufferInfo* imageBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
loadImage:	lw $a3, 0($a0)  # int* buffer
		lw $a1, 4($a0)  # int width
		lw $a2, 8($a0)  # int height
		lw $a0, 12($a0) # char* filename
		mul $t0, $a1, $a2 # words to read (width x height) in a2
		sll $t0, $t0, 2	  # multiply by 4 to get bytes to read
		li $a1, 0     # flags (0: read, 1: write)
		li $a2, 0     # mode (unused)
		li $v0, 13    # open file, $a0 is null-terminated string of file name
		syscall
		move $a0, $v0     # file descriptor (negative if error) as argument for read
  		move $a1, $a3     # address of buffer to which to write
		move $a2, $t0	  # number of bytes to read
		li  $v0, 14       # system call for read from file
		syscall           # read from file
        		# $v0 contains number of characters read (0 if end-of-file, negative if error).
        		# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0, $a3	   # start address
		add $t1, $a3, $a2  # end address
loadloop:	lw $t2, ($t0)
		sw $t2, ($t0)
		addi $t0, $t0, 4
		bne $t0, $t1, loadloop
		jr $ra
		
		
#####################################################
# (offset, score) = findBest( bufferInfo errorBuffer )
# Returns the address offset and score of the best match in the error Buffer
findBest:	lw $t0, 0($a0)     # load error buffer start address	
		lw $t2, 4($a0)	   # load width
		lw $t3, 8($a0)	   # load height
		addi $t3, $t3, -7  # height less 8 template lines minus one
		mul $t1, $t2, $t3
		sll $t1, $t1, 2    # error buffer size in bytes	
		add $t1, $t0, $t1  # error buffer end address
		li $v0, 0		# address of best match	
		li $v1, 0xffffffff 	# score of best match	
		lw $a1, 4($a0)    # load width
        		addi $a1, $a1, -7 # initialize column count to 7 less than width to account for template
fbLoop:		lw $t9, 0($t0)        # score
		sltu $t8, $t9, $v1    # better than best so far?
		beq $t8, $zero, notBest
		move $v0, $t0
		move $v1, $t9
notBest:		addi $a1, $a1, -1
		bne $a1, $0, fbNotEOL # Need to skip 8 pixels at the end of each line
		lw $a1, 4($a0)        # load width
        		addi $a1, $a1, -7     # column count for next line is 7 less than width
        		addi $t0, $t0, 28     # skip pointer to end of line (7 pixels x 4 bytes)
fbNotEOL:	add $t0, $t0, 4
		bne $t0, $t1, fbLoop
		lw $t0, 0($a0)     # load error buffer start address	
		sub $v0, $v0, $t0  # return the offset rather than the address
		jr $ra
		

#####################################################
# highlight( bufferInfo imageBuffer, int offset )
# Applies green mask on all pixels in an 8x8 region
# starting at the provided addr.
highlight:	lw $t0, 0($a0)     # load image buffer start address
		add $a1, $a1, $t0  # add start address to offset
		lw $t0, 4($a0) 	# width
		sll $t0, $t0, 2	
		li $a2, 0xff00 	# highlight green
		li $t9, 8	# loop over rows
highlightLoop:	lw $t3, 0($a1)		# inner loop completely unrolled	
		and $t3, $t3, $a2
		sw $t3, 0($a1)
		lw $t3, 4($a1)
		and $t3, $t3, $a2
		sw $t3, 4($a1)
		lw $t3, 8($a1)
		and $t3, $t3, $a2
		sw $t3, 8($a1)
		lw $t3, 12($a1)
		and $t3, $t3, $a2
		sw $t3, 12($a1)
		lw $t3, 16($a1)
		and $t3, $t3, $a2
		sw $t3, 16($a1)
		lw $t3, 20($a1)
		and $t3, $t3, $a2
		sw $t3, 20($a1)
		lw $t3, 24($a1)
		and $t3, $t3, $a2
		sw $t3, 24($a1)
		lw $t3, 28($a1)
		and $t3, $t3, $a2
		sw $t3, 28($a1)
		add $a1, $a1, $t0	# increment address to next row	
		add $t9, $t9, -1		# decrement row count
		bne $t9, $zero, highlightLoop
		jr $ra

######################################################
# processError( bufferInfo error )
# Remaps scores in the entire error buffer. The best score, zero, 
# will be bright green (0xff), and errors bigger than 0x4000 will
# be black.  This is done by shifting the error by 5 bits, clamping
# anything bigger than 0xff and then subtracting this from 0xff.
processError:	lw $t0, 0($a0)     # load error buffer start address
		lw $t2, 4($a0)	   # load width
		lw $t3, 8($a0)	   # load height
		addi $t3, $t3, -7  # height less 8 template lines minus one
		mul $t1, $t2, $t3
		sll $t1, $t1, 2    # error buffer size in bytes	
		add $t1, $t0, $t1  # error buffer end address
		lw $a1, 4($a0)     # load width as column counter
        		addi $a1, $a1, -7  # initialize column count to 7 less than width to account for template
pebLoop:		lw $v0, 0($t0)        # score
		srl $v0, $v0, 5       # reduce magnitude 
		slti $t2, $v0, 0x100  # clamp?
		bne  $t2, $zero, skipClamp
		li $v0, 0xff          # clamp!
skipClamp:	li $t2, 0xff	      # invert to make a score
		sub $v0, $t2, $v0
		sll $v0, $v0, 8       # shift it up into the green
		sw $v0, 0($t0)
		addi $a1, $a1, -1        # decrement column counter	
		bne $a1, $0, pebNotEOL   # Need to skip 8 pixels at the end of each line
		lw $a1, 4($a0)        # load width to reset column counter
        		addi $a1, $a1, -7     # column count for next line is 7 less than width
        		addi $t0, $t0, 28     # skip pointer to end of line (7 pixels x 4 bytes)
pebNotEOL:	add $t0, $t0, 4
		bne $t0, $t1, pebLoop
		jr $ra
