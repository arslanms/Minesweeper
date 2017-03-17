

.macro smiley_macro(%register)
	li $t4, 0 #Will hold offset for each calculation
    	lw $t7, starting_address
	mul $t4, $t5, $t3 #i * num_columns
    	add $t4, $t4, $t6 #i * num_columns + j
    	mul $t4, $t4, $t2 #element_size * (i * num_columns + j)
    	add $t7, $t7, $t4 #offset
    	sh %register, ($t7)
.end_macro

.macro reset_registers
	add $t0, $0, $0
	add $t1, $0, $0
	add $t2, $0, $0
	add $t3, $0, $0
	add $t4, $0, $0
	add $t5, $0, $0
	add $t6, $0, $0
	add $t7, $0, $0
	add $t8, $0, $0
	add $t9, $0, $0
.end_macro

.text


smiley:
    
    #Define your code here
    
    reset_registers
    
    lw $t0, starting_address
    lw $t1, ending_address
    li $t2, 0x00000f00 #Black background - white foreground - blank ascii
    
    loop: #Resetting the entire board to 0xf00
    
    	bgt $t0, $t1, endLoop
    	sh $t2, ($t0)
    	addi $t0, $t0, 2
    	j loop
    
    endLoop:
    
    	li $t0, 0x0000b762 #Eyes
    	li $t1, 0x00001f65 #Mouth
    	li $t2, 2 #Element size
    	li $t3, 10 #Num columns
    	
    	li $t5, 2 #i value
    	li $t6, 3 #j value
    	smiley_macro($t0)
    	
    	li $t5, 3 #i value
    	li $t6, 3 #j value
    	smiley_macro($t0)
    	
    	li $t5, 2 #i value
    	li $t6, 6 #j value
    	smiley_macro($t0)
    	
    	li $t5, 3 #i value
    	li $t6, 6 #j value
    	smiley_macro($t0)
    	
    	###########START MOUTH HERE ################
    	
    	li $t5, 6 #i value
    	li $t6, 2 #j value
    	smiley_macro($t1)
    	
    	li $t5, 7 #i value
    	li $t6, 3 #j value
    	smiley_macro($t1)
    	
    	li $t5, 8 #i value
    	li $t6, 4 #j value
    	smiley_macro($t1)
    	
    	li $t5, 8 #i value
    	li $t6, 5 #j value
    	smiley_macro($t1)
    	
    	li $t5, 7 #i value
    	li $t6, 6 #j value
    	smiley_macro($t1)
    	
    	li $t5, 6 #i value
    	li $t6, 7 #j value
    	smiley_macro($t1)
    	
	jr $ra



open_file:

    reset_registers
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    
    #a0 contains the file name
    li $a1, 0 #Set the flag to 0 - read only
    li $a2, 0 #Mode is ignored
    li $v0, 13 #Syscall for opening a file (name in a0)
    syscall
    #File descriptor is stored into $v0, which is also our return parameter
    ###########################################
    jr $ra

close_file:
    
    reset_registers
    #Define your code here
    li $v0, 16
    syscall
    ###########################################
    jr $ra

load_map:
    
    addi $sp, $sp, -32 #Gunna need these for calculations
    sw $s0, ($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    
    ###############RESET CELL ARRAY SPACE###################
    reset_registers
    li $t0, 100
    move $t1, $a1
    move $s4, $a1 #####HOLDS THE CELL ARRAY START ADDRESS########
    
    resetSpaceLoop:
    
    	beqz $t0, loadEntireFile_before
    	sb $0, ($t1)
    	addi $t1, $t1, 1
    	addi $t0, $t0, -1
    	j resetSpaceLoop
    	
    loadEntireFile_before:
    
    	li $t2, '0' #To subtract from the char num
    	li $t3, 0 #Num of letters per coord counter
    	li $t4, 0 #Num of bombs in total counter
    	li $t5, 2 #Max amt of numbers allowed per coord
    	li $t6, 99 #Max num of bombs
    	li $t8, 0 #Will hold the first num
    	li $t9, 0 #Will hold the second num
    	#li $t7, 0 #CHecks for next byte
    	move $s0, $s4 #Move the initial base address to s0 for calculations
    	move $a1, $s4
    	li $s1, 10 #Num of columns
    	li $s2, 0x20 #32, 1000
    	
    loadEntireFile:
    	
    	li $v0, 14
    	#a0 is the file descriptor
    	la $a1, buffer
    	li $a2, 1
    	syscall
    	
    	beqz $v0, endOfFile #indicates the end of the file
    	bltz $v0, load_map_error #indicates an error when loading from the file
    	
    	lb $t0, buffer #Holds the character from the file
    	
    
    	innerWhileEachLine:
    	
    		#lb $t1, ($t0) #Holds the character
    		#beqz $t1, endOfString
    		beq $t0, '\n', innerWhile_NotNum
    		beq $t0, '\t', innerWhile_NotNum
    		beq $t0, ' ', innerWhile_NotNum
    		beq $t0, '\r', innerWhile_NotNum
    		bge $t0, '0', checkIfLessOrEq9
    		j load_map_error
    		
    		checkIfLessOrEq9:
    		
    			ble $t0, '9', innerWhile_Num
    			j load_map_error
    			
    		innerWhile_NotNum:
    		
    			j loadEntireFile
    		
    		innerWhile_Num:
    		
    			#MUST CHECK IF THE NEXT BYTE IS A NUM AS WELL
    			#lb $t7, 1($t0) #Get the next byte
    			#beqz $t7, cont_innerWhile_Num
    			#beq $t7, '\n', cont_innerWhile_Num
    			#beq $t7, '\t', cont_innerWhile_Num
    			#beq $t7, ' ', cont_innerWhile_Num
    			#beq $t7, '\r', cont_innerWhile_Num
    			#bge $t7, '0', innerWhile_Num_checkIfNum
    			#j load_map_error
    			
    			#innerWhile_Num_checkIfNum:
    			
    			#ble $t7, '9', load_map_error
    			#j cont_innerWhile_Num
    			
    			#cont_innerWhile_Num:
    			
    			beqz $t3, firstNum
    			j secondNum
    			
    			firstNum:
    			
    				sub $t0, $t0, $t2 #Contains the actual num
    				#addi $t0, $t0, 1 #increment buffer
    				#addi $t3, $t3, 1 #Add one to the num of characters in this line
    				#t0 has the actual number
    				mul $t8, $t8, $s1 #sum = sum * 10
    				add $t8, $t8, $t0 #sum += number
    				
    				li $v0, 14
    				#a0 is the file descriptor
    				la $a1, buffer
    				li $a2, 1
    				syscall
    				
    				beqz $v0, end_firstNum_1 #Added this line
    				bltz $v0, load_map_error #Added this line
    				
    				lb $t0, buffer
    				blt $t0, '0', end_firstNum
    				bgt $t0, '9', end_firstNum
    				
    				#move $t8, $t2
    				#li $t2, '0'
    				j firstNum
    				
    			secondNum:
    				sub $t0, $t0, $t2 #Contains the actual num
    				#addi $t0, $t0, 1 #increment buffer
    				#addi $t3, $t3, 1 #Add one to the num of characters in this line
    				#t0 has the actual number
    				mul $t9, $t9, $s1 #sum = sum * 10
    				add $t9, $t9, $t0 #sum += number
    				
    				li $v0, 14
    				#a0 is the file descriptor
    				la $a1, buffer
    				li $a2, 1
    				syscall
    				
    				beqz $v0, end_firstNum_2 #Added this line
    				bltz $v0, load_map_error #Added this line
    				
    				lb $t0, buffer
    				blt $t0, '0', end_secondNum
    				bgt $t0, '9', end_secondNum
    				
    				#move $t8, $t2
    				#li $t2, '0'
    				j secondNum
    				
    				
    			end_secondNum:
    			
    				beq $t0, '\n', end_firstNum_2
    				beq $t0, '\t', end_firstNum_2
    				beq $t0, ' ', end_firstNum_2
    				beq $t0, '\r', end_firstNum_2
    				j load_map_error
    			
    				end_firstNum_2:
    				move $a1, $s4 #reset $a1
    				mul $t8, $t8, $s1 #i * num_columns
    				add $t8, $t8, $t9 #i * num_columns + j
    				add $a1, $a1, $t8 #add to the base address
    				
    				#We must check if this is an unused bomb or not
    				lb $s3, ($a1) #Get the byte
    				beq $s3, $s2, duplicateBomb
    				j newBomb
    				
    				duplicateBomb:
    				
    				move $a1, $s4 #Reset $a1
    				li $t8, 0
    				li $t9, 0
    				li $t3, 0
    				j loadEntireFile
    				
    				newBomb:
    				
    				sb $s2, ($a1) #Store the bomb
    				
    				move $a1, $s4 #Reset $a1
    				li $t8, 0
    				li $t9, 0
    				li $t3, 0 #reset the coord counter
    				addi $t4, $t4, 1 #Add to the bombs counter
    				
    				j loadEntireFile
    				
    		end_firstNum:
    			beq $t0, '\n', end_firstNum_1
    			beq $t0, '\t', end_firstNum_1
    			beq $t0, ' ', end_firstNum_1
    			beq $t0, '\r', end_firstNum_1
    			j load_map_error
    			
    			end_firstNum_1:
    			
    			bgt $t8, 9, load_map_error #num cannot be greater than 9
    			addi $t3, $t3, 1
    			j loadEntireFile
    	
    		endOfFile:
    		#addi $t5, $t5, -1
    		beq $t3, 1, load_map_error
    		bgt $t4, 99, load_map_error
    		blt $t4, 1, load_map_error
    		j addAdjacentBombs
    		
    		
    		addAdjacentBombs:
    		
    		#MUST ADD THE NUMBER OF BOMBS SURROUNDING IN THE CELL ARRAY
    		reset_registers
    		li $s0, 0
    		li $s1, 0
    		li $s2, 0
    		li $s3, 0
    		li $s5, 0
    		li $s6, 0
    		li $s7, 0
    		
    		move $t0, $s4 #has the cells array
    		li $t1, 0 #to compare to a 0
    		li $t2, 9 #to compare to a 9
    		li $t3, 32 #to check if it is a bomb
    		li $t4, 100 #for loop case
    		li $t6, 0
    		li $t7, 10
    		
    		addAdjacentBombsLoop:
    		
    			beq $t6, $t4, end_loadmap
    			lb $t5, ($t0) #get the byte
    			and $t5, $t5, $t3 #check if it is a bomb
    			beq $t5, $t3, addAdjacentBombsLoop_isBomb
    			addi $t6, $t6, 1
    			addi $t0, $t0, 1
    			j addAdjacentBombsLoop
    			
    			addAdjacentBombsLoop_isBomb:
    			
    				div $t6, $t7 #will hold the row in the lo and the col in the hi
    				mflo $t8 #holds the row
    				mfhi $t9 #holds the col
    				
   				beq $t8, $t1, addAdjacentBombsLoop_rowIsZero
   				beq $t8, $t2, addAdjacentBombsLoop_rowIsNine
   				beq $t9, $t1, addAdjacentBombsLoop_colIsZero
   				beq $t9, $t2, addAdjacentBombsLoop_colIsNine
   				j addAdjacentBombsLoop_regularPos
   				
   				addAdjacentBombsLoop_rowIsZero:
   				
   					beq $t9, $t1, addAdjacentBombsLoop_rowIsZero_upperLeft
   					beq $t9, $t2, addAdjacentBombsLoop_rowIsZero_upperRight
   					j addAdjacentBombsLoop_rowIsZero_side
   					
   					addAdjacentBombsLoop_rowIsZero_upperLeft:
   					
   						lb $s0, 1($t0)
   						addi $s0, $s0, 1
   						sb $s0, 1($t0)
   						
   						lb $s0, 10($t0)
   						addi $s0, $s0, 1
   						sb $s0, 10($t0)
   						
   						lb $s0, 11($t0)
   						addi $s0, $s0, 1
   						sb $s0, 11($t0)
   						
   						addi $t0, $t0, 1
    						addi $t6, $t6, 1
    						j addAdjacentBombsLoop
   					
   					addAdjacentBombsLoop_rowIsZero_upperRight:
   					
   						lb $s0, -1($t0)
   						addi $s0, $s0, 1
   						sb $s0, -1($t0)
   						
   						lb $s0, 9($t0)
   						addi $s0, $s0, 1
   						sb $s0, 9($t0)
   						
   						lb $s0, 10($t0)
   						addi $s0, $s0, 1
   						sb $s0, 10($t0)
   						
   						addi $t0, $t0, 1
    						addi $t6, $t6, 1
    						j addAdjacentBombsLoop
   					
   					addAdjacentBombsLoop_rowIsZero_side:
   					
   						lb $s0, -1($t0)
   						addi $s0, $s0, 1
   						sb $s0, -1($t0)
   					
   						lb $s0, 1($t0)
   						addi $s0, $s0, 1
   						sb $s0, 1($t0)
   					
   						lb $s0, 9($t0)
   						addi $s0, $s0, 1
   						sb $s0, 9($t0)
   					
   						lb $s0, 10($t0)
   						addi $s0, $s0, 1
   						sb $s0, 10($t0)
   					
   						lb $s0, 11($t0)
   						addi $s0, $s0, 1
   						sb $s0, 11($t0)
   					
   						addi $t0, $t0, 1
    						addi $t6, $t6, 1
    						j addAdjacentBombsLoop
   				
   				addAdjacentBombsLoop_rowIsNine:  
   				
   					beq $t9, $t1, addAdjacentBombsLoop_rowIsNine_bottomLeft
   					beq $t9, $t2, addAdjacentBombsLoop_rowIsNine_bottomRight
   					j addAdjacentBombsLoop_rowIsNine_side
   					
   					addAdjacentBombsLoop_rowIsNine_bottomLeft:
   					
   						lb $s0, -10($t0)
   						addi $s0, $s0, 1
   						sb $s0, -10($t0)
   						
   						lb $s0, -9($t0)
   						addi $s0, $s0, 1
   						sb $s0, -9($t0)
   						
   						lb $s0, 1($t0)
   						addi $s0, $s0, 1
   						sb $s0, 1($t0)
   						
   						addi $t0, $t0, 1
    						addi $t6, $t6, 1
    						j addAdjacentBombsLoop
   					
   					addAdjacentBombsLoop_rowIsNine_bottomRight:
   					
   						lb $s0, -11($t0)
   						addi $s0, $s0, 1
   						sb $s0, -11($t0)
   						
   						lb $s0, -10($t0)
   						addi $s0, $s0, 1
   						sb $s0, -10($t0)
   						
   						lb $s0, -1($t0)
   						addi $s0, $s0, 1
   						sb $s0, -1($t0)
   						
   						addi $t0, $t0, 1
    						addi $t6, $t6, 1
    						j addAdjacentBombsLoop
   					
   					addAdjacentBombsLoop_rowIsNine_side:
   					
   						lb $s0, -11($t0)
   						addi $s0, $s0, 1
   						sb $s0, -11($t0)
   					
   						lb $s0, -10($t0)
   						addi $s0, $s0, 1
   						sb $s0, -10($t0)
   					
   						lb $s0, -9($t0)
   						addi $s0, $s0, 1
   						sb $s0, -9($t0)
   					
   						lb $s0, -1($t0)
   						addi $s0, $s0, 1
   						sb $s0, -1($t0)
   					
   						lb $s0, 1($t0)
   						addi $s0, $s0, 1
   						sb $s0, 1($t0)
   					
   						addi $t0, $t0, 1
    						addi $t6, $t6, 1
    						j addAdjacentBombsLoop
   				
   				addAdjacentBombsLoop_colIsZero:
   				
   					lb $s0, -10($t0)
   					addi $s0, $s0, 1
   					sb $s0, -10($t0)
   					
   					lb $s0, -9($t0)
   					addi $s0, $s0, 1
   					sb $s0, -9($t0)
   					
   					lb $s0, 1($t0)
   					addi $s0, $s0, 1
   					sb $s0, 1($t0)
   					
   					lb $s0, 10($t0)
   					addi $s0, $s0, 1
   					sb $s0, 10($t0)
   					
   					lb $s0, 11($t0)
   					addi $s0, $s0, 1
   					sb $s0, 11($t0)
   					
   					addi $t0, $t0, 1
    					addi $t6, $t6, 1
    					j addAdjacentBombsLoop
   				
   				addAdjacentBombsLoop_colIsNine:
   				
   					lb $s0, -11($t0)
   					addi $s0, $s0, 1
   					sb $s0, -11($t0)
   					
   					lb $s0, -10($t0)
   					addi $s0, $s0, 1
   					sb $s0, -10($t0)
   					
   					lb $s0, -1($t0)
   					addi $s0, $s0, 1
   					sb $s0, -1($t0)
   					
   					lb $s0, 9($t0)
   					addi $s0, $s0, 1
   					sb $s0, 9($t0)
   					
   					lb $s0, 10($t0)
   					addi $s0, $s0, 1
   					sb $s0, 10($t0)
   					
   					addi $t0, $t0, 1
    					addi $t6, $t6, 1
    					j addAdjacentBombsLoop
   				
   				addAdjacentBombsLoop_regularPos:
   				
   					lb $s0, -11($t0)
   					addi $s0, $s0, 1
   					sb $s0, -11($t0)
   					
   					lb $s0, -10($t0)
   					addi $s0, $s0, 1
   					sb $s0, -10($t0)
   					
   					lb $s0, -9($t0)
   					addi $s0, $s0, 1
   					sb $s0, -9($t0)
   					
   					lb $s0, -1($t0)
   					addi $s0, $s0, 1
   					sb $s0, -1($t0)
   					
   					lb $s0, 1($t0)
   					addi $s0, $s0, 1
   					sb $s0, 1($t0)
   					
   					lb $s0, 9($t0)
   					addi $s0, $s0, 1
   					sb $s0, 9($t0)
   					
   					lb $s0, 10($t0)
   					addi $s0, $s0, 1
   					sb $s0, 10($t0)
   					
   					lb $s0, 11($t0)
   					addi $s0, $s0, 1
   					sb $s0, 11($t0)
    					
    					addi $t0, $t0, 1
    					addi $t6, $t6, 1
    					j addAdjacentBombsLoop
    				
    	
    load_map_error:
    
    	
    	lw $s0, ($sp)
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s5, 20($sp)
    	lw $s6, 24($sp)
    	lw $s7, 28($sp)
    	addi $sp, $sp, 32 #Gunna need these for calculations
    	
    	li $v0, -1
    	jr $ra
    	
    end_loadmap:
    
    reset_registers
    li $t0, 0
    sw $t0, cursor_row
    sw $t0, cursor_col
    
    lw $s0, ($sp)
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s5, 20($sp)
    	lw $s6, 24($sp)
    	lw $s7, 28($sp)
    	addi $sp, $sp, 32 #Gunna need these for calculations
    ###########################################
    li $v0, 0 #Changed this line
    jr $ra



init_display:
    
        
    reset_registers
    
    lw $t0, starting_address
    addi $t0, $t0, 2 #CHANGED LINE, START THE LOOP AT 2ND CELL
    lw $t1, ending_address
    li $t2, 0x00007700 #gray background - gray foreground - blank ascii
    
    initloop: #Resetting the entire board to 0x7000
    
    	bgt $t0, $t1, changeCursor
    	sh $t2, ($t0)
    	addi $t0, $t0, 2
    	j initloop
    	
    changeCursor:
    
    lw $t0, starting_address
    lw $t1, cursor_row
    lw $t2, cursor_col
    li $t3, 0xFFFF0FFF #yellow background - gray foreground - blank ascii #CHANGED LINE
    li $t4, 2 #Size of box
    li $t5, 10 #Num of columns
    
    mul $t1, $t1, $t5 #i * num columns
    add $t1, $t1, $t2 #i * num columns + j
    mul $t1, $t1, $t4 #i * num columns + j all times size per cell
    add $t0, $t0, $t1 #add to the address
    lh $t9, ($t0) #CHANGED LINE
    and $t3, $t9, $t3 #CHANGED LINE
    ori $t3, $t3, 0x0000B000 #CHANGED LINE
    sh $t3, ($t0)
    
    jr $ra

set_cell:
	
	#a0 contains the row 0<=row<10
	#a1 contains the col 0<=col<10
	#a2 contains the char ch (does not need to be checked)
	#a3 contains the fg color 0<=FG<=15
	#a4/t0 contains the bg color 0<=BG<=15
	
	#a4 will be on the stack because it is a fifth argument
	
	reset_registers
	lw $t0, ($sp) #Get the argumenet from the stack
	li $t1, 0
	li $t2, 10
	li $t3, 15
	li $t4, 2 #Size of each cell in the MMIO
	li $t5, 10 #Num of columns
	lw $t6, starting_address
	#These are for comparisons
	
	blt $a0, $t1, error_set_cell
	bge $a0, $t2, error_set_cell
	blt $a1, $t1, error_set_cell
	bge $a1, $t2, error_set_cell
	blt $a3, $t1, error_set_cell
	bgt $a3, $t3, error_set_cell
	blt $t0, $t1, error_set_cell
	bgt $t0, $t3, error_set_cell
	j cont_set_cell
	
	cont_set_cell:
	
	sll $t0, $t0, 4 #Shift the background 4 bits the the left -make room for fg
	add $t0, $t0, $a3 #Add fg to the 4 bits
	sll $t0, $t0, 8 #Shift bg/fg 8 bits to the left to make room for the char
	add $t0, $t0, $a2 #Add the char to the t0 register
	#t0 holds the half word
	
	mul $a0, $a0, $t5 #i * numcols
	add $a0, $a0, $a1 #i *numcols + j
	mul $a0, $a0, $t4 #(i*numcols+j)(elemsize)
	add $t6, $t6, $a0 #add to the base addr
	
	sh $t0, ($t6) #Store the half word into the cell
	
	li $v0, 0
	jr $ra
	
	
	error_set_cell:
	
	li $v0, -1
	jr $ra

reveal_map:
    
    #a0 is the game status, 1 is win, 0 is ongoing, -1 is loss
    #a1 is the cells array
    reset_registers
    li $t0, 1
    li $t1, -1
    
    beq $a0, $t0, revealmap_won
    beq $a0, $t1, revealmap_loss
    j nothinghappens
    
    revealmap_loss:
    
    li $a0, -1
    addi $sp, $sp, -4
    sw $ra, ($sp)
    jal set_cell
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    reset_registers
    
    lw $t2, starting_address
    lw $t3, ending_address
    
    revealmapLoop:
    
    	bgt $t2, $t3, endRevealMapLoop
    	lb $t0, ($a1) #Get the byte from the array
    	li $t1, 64
    	and $t0, $t0, $t1
    	beq $t0, $t1, hasBeenRevealed
    	j hasNotBeenRevealed
    	
    	hasBeenRevealed:
    	
    		addi $a1, $a1, 1
    		addi $t2, $t2, 2
    		j revealmapLoop
    		
    	
    	hasNotBeenRevealed:
    	
    	#If the cell has not been revealed, it can either contain a bomb, be flagged, or be a number
    	lb $t0, ($a1)
    	li $t1, 32
    	and $t0, $t0, $t1
    	beq $t0, $t1, isABomb
    	j notABomb
    	
    		isABomb:
    		
    			#check if it is flagged or nahhhhh
    			lb $t0, ($a1)
    			li $t1, 16
    			and $t0, $t0, $t1
    			beq $t0, $t1, isFlaggedBomb
    			j isNotFlaggedBomb
    			
    			isFlaggedBomb:
    			
    				li $t0, 0xAC66 #FlaggedBomb
    				sh $t0, ($t2)
    				addi $a1, $a1, 1
    				addi $t2, $t2, 2
    				j revealmapLoop
    			
    			isNotFlaggedBomb:
    			
    				li $t0, 0x0762
    				sh $t0, ($t2)
    				addi $a1, $a1, 1
    				addi $t2, $t2, 2
    				j revealmapLoop
    		
    		notABomb:
    		
    		
    			lb $t0, ($a1)
    			li $t1, 16
    			and $t0, $t0, $t1
    			beq $t0, $t1, isFlaggedNotABomb
    			j isNotFlaggedNotABomb
    			
    			
    			isFlaggedNotABomb:
    			
    				li $t0, 0x9C66
    				sh $t0, ($t2)
    				addi $a1, $a1, 1
    				addi $t2, $t2, 2
    				j revealmapLoop
    			
    			isNotFlaggedNotABomb:
    			
    				lb $t0, ($a1)
    				li $t1, 15
    				and $t0, $t0, $t1
    				addi $t0, $t0, '0'
    				beq $t0, '0', isNotFlaggedNotABombEmpty
    				j isNotFlaggedNotABombNum
    				
    				isNotFlaggedNotABombEmpty:
    				
    					li $t0, 0x0F00
    					sh $t0, ($t2)
    					addi $a1, $a1, 1
    					addi $t2, $t2, 2
    					j revealmapLoop
    				
    				isNotFlaggedNotABombNum:
    				
    					#t0 has the ascii
    					li $t1, 0x0D #has the bg and fg together
    					sll $t1, $t1, 8
    					add $t1, $t0, $t1
    					sh $t1, ($t2)
    					addi $a1, $a1, 1
    					addi $t2, $t2, 2
    					j revealmapLoop
    	
    
    endRevealMapLoop:
    
    lw $t0, cursor_row
    lw $t1, cursor_col
    li $t2, 2
    li $t3, 10
    li $t4, 0x00009f65 #Red bg, white fg, bomb
    lw $t5, starting_address
    
    mul $t0, $t0, $t3
    add $t0, $t0, $t1
    mul $t0, $t0, $t2
    add $t5, $t5, $t0
    
    sh $t4, ($t5) #Store the bomb at the cursor
    jr $ra
    
    
    
    revealmap_won:
    
    addi $sp, $sp, -4
    sw $ra, ($sp)
    jal smiley
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra
    
    nothinghappens:
    jr $ra



perform_action:
    
    #a0 has the cells array
    #a1 has the byte/ascii that corresponds to the action
    reset_registers
    move $t9, $a0 #has the cell array
    
    beq $a1, 'w', moveCursorUp
    beq $a1, 'W', moveCursorUp
    beq $a1, 'a', moveCursorLeft
    beq $a1, 'A', moveCursorLeft
    beq $a1, 'd', moveCursorRight
    beq $a1, 'D', moveCursorRight
    beq $a1, 's', moveCursorDown
    beq $a1, 'S', moveCursorDown
    beq $a1, 'r', revealCursor
    beq $a1, 'R', revealCursor
    beq $a1, 'f', toggleFlag
    beq $a1, 'F', toggleFlag
    
    moveCursorUp:
    
	lw $t0, cursor_row #i
	lw $t1, cursor_col #j
	beqz $t0, error_perform_action #If i is zero, we cannot move up, so return -1
	li $t2, 10 #Num of cols
	
	mul $t0, $t0, $t2 #i * num_colums
	add $t0, $t0, $t1 #i * num_columns + j
	add $a0, $a0, $t0 #Cell array so we dont multiply by 2, add to address
	
	lb $t3, ($a0) #Get the byte from the cells array must check if its revealed or not
	li $t4, 64
	
	and $t3, $t3, $t4 #and it to see if it is equal to 64 to know if it is revealed or not
	beq $t3, $t4, moveCursorUp_isRevealed
	j moveCursorUp_isNotRevealed
	
		moveCursorUp_isRevealed:
		
			li $t4, 2
			mul $t0, $t0, $t4 #Multiply by two so we can use this to access the mmio
			lw $t4, starting_address
			add $t4, $t4, $t0 #Adds the offset to the starting address
			
			lh $t2, ($t4) #Get the mmio byte contains bg and fg
			andi $t2, $t2, 0x0FFF #15 is 0000 1111 which turns the bg black and preserves the fg
			sh $t2, ($t4)
			
			lh $t2, -20($t4) #Get the byte right above
			andi $t2, $t2, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t2, $t2, 0xB000 #Makes the bg yellow
			sh $t2, -20($t4)
			
			lw $t1, cursor_row
			addi $t1, $t1, -1
			sw $t1, cursor_row
			
			j success_perform_action
		
		moveCursorUp_isNotRevealed:
		
			li $t4, 2
			mul $t0, $t0, $t4
			lw $t4, starting_address
			add $t4, $t4, $t0
			
			lh $t2, ($t4)
			andi $t2, $t2, 0x0FFF
			ori $t2, $t2, 0x7000
			sh $t2, ($t4)
			
			lh $t2, -20($t4) #Get the byte right above
			andi $t2, $t2, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t2, $t2, 0xB000 #Makes the bg yellow
			sh $t2, -20($t4)
			
			lw $t1, cursor_row
			addi $t1, $t1, -1
			sw $t1, cursor_row
			
			j success_perform_action
	
	
    moveCursorLeft:
    
    	lw $t0, cursor_col #j
    	lw $t1, cursor_row #i
	beqz $t0, error_perform_action
	li $t2, 10 #Num of cols
	
	mul $t1, $t1, $t2
	add $t1, $t1, $t0
	add $a0, $a0, $t1
	
	lb $t3, ($a0) #Get the byte from the cells array must check if its revealed or not
	li $t4, 64
	
	and $t3, $t3, $t4 #and it to see if it is equal to 64 to know if it is revealed or not
	beq $t3, $t4, moveCursorLeft_isRevealed
	j moveCursorLeft_isNotRevealed
	
	moveCursorLeft_isRevealed:
	
			li $t4, 2
			mul $t1, $t1, $t4 #Multiply by two so we can use this to access the mmio
			lw $t4, starting_address
			add $t4, $t4, $t1 #puts the address in t0
			
			lh $t2, ($t4) #Get the mmio byte contains bg and fg
			andi $t2, $t2, 0x0FFF #15 is 0000 1111 which turns the bg black and preserves the fg
			sh $t2, ($t4)
			
			lh $t2, -2($t4) #Get the byte right above
			andi $t2, $t2, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t2, $t2, 0xB000 #Makes the bg yellow
			sh $t2, -2($t4)
			
			lw $t1, cursor_col
			addi $t1, $t1, -1
			sw $t1, cursor_col
			
			j success_perform_action
	
	moveCursorLeft_isNotRevealed:
	
			li $t4, 2
			mul $t1, $t1, $t4 #Multiply by two so we can use this to access the mmio
			lw $t4, starting_address
			add $t4, $t4, $t1 #puts the address in t0
			
			lh $t2, ($t4)
			andi $t2, $t2, 0x0FFF
			ori $t2, $t2, 0x7000
			sh $t2, ($t4)
			
			lh $t2, -2($t4) #Get the byte right above
			andi $t2, $t2, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t2, $t2, 0xB000 #Makes the bg yellow
			sh $t2, -2($t4)
			
			lw $t1, cursor_col
			addi $t1, $t1, -1
			sw $t1, cursor_col
			
			j success_perform_action
    
    moveCursorRight:
    
    	lw $t0, cursor_col #j
    	li $t1, 9
    	lw $t2, cursor_row #i
	beq $t0, $t1, error_perform_action
	li $t1, 10 #Num of cols
	
	mul $t2, $t2, $t1
	add $t2, $t2, $t0
	add $a0, $a0, $t2
	
	lb $t3, ($a0) #Get the byte from the cells array must check if its revealed or not
	li $t4, 64
	
	and $t3, $t3, $t4 #and it to see if it is equal to 64 to know if it is revealed or not
	beq $t3, $t4, moveCursorRight_isRevealed
	j moveCursorRight_isNotRevealed
	
	moveCursorRight_isRevealed:
	
			li $t4, 2
			mul $t2, $t2, $t4 #Multiply by two so we can use this to access the mmio
			lw $t4, starting_address
			add $t4, $t4, $t2 #puts the address in t0
			
			lh $t1, ($t4) #Get the mmio byte contains bg and fg
			andi $t1, $t1, 0x0FFF #15 is 0000 1111 which turns the bg black and preserves the fg
			sh $t1, ($t4)
			
			lh $t1, 2($t4) #Get the byte right above
			andi $t1, $t1, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t1, $t1, 0xB000 #Makes the bg yellow
			sh $t1, 2($t4)
			
			lw $t1, cursor_col
			addi $t1, $t1, 1
			sw $t1, cursor_col
			
			j success_perform_action
	
	moveCursorRight_isNotRevealed:
	
			li $t4, 2
			mul $t2, $t2, $t4 #Multiply by two so we can use this to access the mmio
			lw $t4, starting_address
			add $t4, $t4, $t2 #puts the address in t0
			
			lh $t1, ($t4) #Get the mmio byte contains bg and fg
			andi $t1, $t1, 0x0FFF #15 is 0000 1111 which turns the bg black and preserves the fg
			ori $t1, $t1, 0x7000
			sh $t1, ($t4)
			
			lh $t1, 2($t4) #Get the byte right above
			andi $t1, $t1, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t1, $t1, 0xB000 #Makes the bg yellow
			sh $t1, 2($t4)
			
			lw $t1, cursor_col
			addi $t1, $t1, 1
			sw $t1, cursor_col
			
			j success_perform_action
    
    moveCursorDown:
    
    	lw $t0, cursor_row #i
    	li $t1, 9
    	lw $t2, cursor_col #j
	beq $t0, $t1, error_perform_action
	li $t1, 10 #Num of cols
	
	mul $t0, $t0, $t1
	add $t0, $t0, $t2
	add $a0, $a0, $t0
	
	lb $t3, ($a0) #Get the byte from the cells array must check if its revealed or not
	li $t4, 64
	
	and $t3, $t3, $t4 #and it to see if it is equal to 64 to know if it is revealed or not
	beq $t3, $t4, moveCursorDown_isRevealed
	j moveCursorDown_isNotRevealed
	
	moveCursorDown_isRevealed:
	
			li $t4, 2
			mul $t0, $t0, $t4 #Multiply by two so we can use this to access the mmio
			lw $t4, starting_address
			add $t4, $t4, $t0
			
			lh $t1, ($t4) #Get the mmio byte contains bg and fg
			andi $t1, $t1, 0x0FFF #15 is 0000 1111 which turns the bg black and preserves the fg
			sh $t1, ($t4)
			
			lh $t1, 20($t4) #Get the byte right above
			andi $t1, $t1, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t1, $t1, 0xB000 #Makes the bg yellow
			sh $t1, 20($t4)
			
			lw $t1, cursor_row
			addi $t1, $t1, 1
			sw $t1, cursor_row
			
			j success_perform_action
	
	moveCursorDown_isNotRevealed:
	
			li $t4, 2
			mul $t0, $t0, $t4 #Multiply by two so we can use this to access the mmio
			lw $t4, starting_address
			add $t4, $t4, $t0
			
			lh $t1, ($t4) #Get the mmio byte contains bg and fg
			andi $t1, $t1, 0x0FFF #15 is 0000 1111 which turns the bg black and preserves the fg
			ori $t1, $t1, 0x7000
			sh $t1, ($t4)
			
			lh $t1, 20($t4) #Get the byte right above
			andi $t1, $t1, 0x0FFF #Reset the bg to black but preserve the fg
			ori $t1, $t1, 0xB000 #Makes the bg yellow
			sh $t1, 20($t4)
			
			lw $t1, cursor_row
			addi $t1, $t1, 1
			sw $t1, cursor_row
			
			j success_perform_action
	
    
    revealCursor:
    
    	#t9 has the cells array
    	#so does a0
    	
    	lw $t0, cursor_row
    	lw $t1, cursor_col
    	li $t2, 10
    	
    	mul $t0, $t0, $t2
    	add $t0, $t0, $t1
    	add $t0, $t0, $t9 #t0 has the offset address
    	
    	lb $t1, ($t0) #t1 has the byte
    	li $t2, 64
    	and $t1, $t1, $t2 #and it with the bit we want
    	beq $t1, $t2, revealCursor_isRevealed
    	j revealCursor_isNotRevealed
    	
    	revealCursor_isRevealed:
    	
    		j error_perform_action
    		
    	revealCursor_isNotRevealed:
    	
    		lb $t1, ($t0) #get the byte again to check if it is a flag or not
    		li $t2, 16
    		and $t1, $t1, $t2
    		beq $t1, $t2, revealCursor_isNotRevealed_isFlag
    		j revealCursor_isNotRevealed_isNotFlag
    		
    		revealCursor_isNotRevealed_isFlag:
    		
    			lb $t1, ($t0) #get the byte again, we want to change the reveal bit and the flag bit
    			ori $t1, $t1, 64
    			andi $t1, $t1, 111
    			sb $t1, ($t0) #changed it so it is now revealed and the flag is removed
    			
    			#we must check if it is a bomb or not
    			lb $t1, ($t0)
    			li $t2, 32
    			and $t1, $t1, $t2
    			beq $t1, $t2, revealCursor_isNotRevealed_isFlag_isBomb
    			j revealCursor_isNotRevealed_isFlag_isNotBomb
    			
    			revealCursor_isNotRevealed_isFlag_isBomb:
    			
    				lw $a0, cursor_row
    				lw $a1, cursor_col
    				li $a2, 'b'
    				li $a3, 7
    				li $t1, 11
    				addi $sp, $sp, -8
    				sw $t1, ($sp)
    				sw $ra, 4($sp)
    				jal set_cell
    				lw $t1, ($sp)
    				lw $ra, 4($sp)
    				addi $sp, $sp, 8
    				j success_perform_action
    			
    			revealCursor_isNotRevealed_isFlag_isNotBomb:
    			
    				lb $a2, ($t0)
    				andi $a2, $a2, 15 #get the number
    				beqz $a2, revealCursor_isNotRevealed_isFlag_isNotBomb_NumIsZero
    				j revealCursor_isNotRevealed_isFlag_isNotBomb_NumIsntZero
    			
    				#CALL SEARCH CELLS IN THIS IF STATEMENT#
    				revealCursor_isNotRevealed_isFlag_isNotBomb_NumIsZero:
    				
    					#lw $a0, cursor_row
    					#lw $a1, cursor_col
    					#a2 has the num zero - empty cell
    					#li $a3, 15
    					#li $t1, 11
    					#addi $sp, $sp, -8
    					#sw $t1, ($sp)
    					#sw $ra, 4($sp)
    					#jal set_cell
    					#lw $t1, ($sp)
    					#lw $ra, 4($sp)
    					#addi $sp, $sp, 8
    					#j success_perform_action
    					
    					addi $sp, $sp, -8
    					sw $ra, ($sp)
    					sw $a0, 4($sp)
    					move $a0, $t9
    					lw $a1, cursor_row
    					lw $a2, cursor_col
    					jal search_cells
    					lw $ra ($sp)
    					lw $a0, 4($sp)
    					addi $sp, $sp, 8
    					j success_perform_action
    					
    				revealCursor_isNotRevealed_isFlag_isNotBomb_NumIsntZero:
    				
    					addi $a2, $a2, '0'
    					lw $a0, cursor_row
    					lw $a1, cursor_col
    					#li $a2, 'b'
    					li $a3, 13
    					li $t1, 11
    					addi $sp, $sp, -8
    					sw $t1, ($sp)
    					sw $ra, 4($sp)
    					jal set_cell
    					lw $t1, ($sp)
    					lw $ra, 4($sp)
    					addi $sp, $sp, 8
    					j success_perform_action
    		
    		revealCursor_isNotRevealed_isNotFlag:
    		
    			lb $t1, ($t0)
    			ori $t1, $t1, 64
    			sb $t1, ($t0) #only have to take away the reveal bit, not the flag part
    			
    			#we must check if it is a bomb or not
    			lb $t1, ($t0)
    			li $t2, 32
    			and $t1, $t1, $t2
    			beq $t1, $t2, revealCursor_isNotRevealed_isNotFlag_isBomb
    			j revealCursor_isNotRevealed_isNotFlag_isNotBomb
    			
    			revealCursor_isNotRevealed_isNotFlag_isBomb:
    			
    				lw $a0, cursor_row
    				lw $a1, cursor_col
    				li $a2, 'b'
    				li $a3, 7
    				li $t1, 11
    				addi $sp, $sp, -8
    				sw $t1, ($sp)
    				sw $ra, 4($sp)
    				jal set_cell
    				lw $t1, ($sp)
    				lw $ra, 4($sp)
    				addi $sp, $sp, 8
    				j success_perform_action
    			
    			revealCursor_isNotRevealed_isNotFlag_isNotBomb:
    			
    				lb $a2, ($t0)
    				andi $a2, $a2, 15 #get the number
    				beqz $a2, revealCursor_isNotRevealed_isNotFlag_isNotBomb_NumIsZero
    				j revealCursor_isNotRevealed_isNotFlag_isNotBomb_NumIsntZero
    			
    				revealCursor_isNotRevealed_isNotFlag_isNotBomb_NumIsZero:
    				
    					
    					
    					addi $sp, $sp, -8
    					sw $ra, ($sp)
    					sw $a0, 4($sp)
    					move $a0, $t9
    					lw $a1, cursor_row
    					lw $a2, cursor_col
    					jal search_cells
    					lw $ra ($sp)
    					lw $a0, 4($sp)
    					addi $sp, $sp, 8
    					#li $a2, 'b'
    					#li $a3, 13
    					#li $t1, 11
    					#addi $sp, $sp, -8
    					#sw $t1, ($sp)
    					#sw $ra, 4($sp)
    					#jal set_cell
    					#lw $t1, ($sp)
    					#lw $ra, 4($sp)
    					#addi $sp, $sp, 8
    					j success_perform_action
    					
    				revealCursor_isNotRevealed_isNotFlag_isNotBomb_NumIsntZero:
    				
    					addi $a2, $a2, '0'
    					lw $a0, cursor_row
    					lw $a1, cursor_col
    					#li $a2, 'b'
    					li $a3, 13
    					li $t1, 11
    					addi $sp, $sp, -8
    					sw $t1, ($sp)
    					sw $ra, 4($sp)
    					jal set_cell
    					lw $t1, ($sp)
    					lw $ra, 4($sp)
    					addi $sp, $sp, 8
    					j success_perform_action
    
    toggleFlag:
    
    	lw $t0, cursor_row
    	lw $t1, cursor_col
    	li $t2, 0
    	li $t3, 10
    	
    	mul $t2, $t0, $t3
    	add $t2, $t2, $t1
    	add $t9, $t9, $t2 #has the offset in the cell array
    	
    	lb $t2, ($t9) #get that byte - need ot check if it is revealed or not
    	li $t3, 64
    	and $t2, $t2, $t3
    	beq $t2, $t3, toggleFlag_hasBeenRevealed
    	j toggleFlag_hasNotBeenRevealed
    	
    	toggleFlag_hasBeenRevealed:
    	
    		j error_perform_action
    		
    	toggleFlag_hasNotBeenRevealed:
    	
    		lb $t2, ($t9) #have to check if it is flagged or not
    		li $t3, 16
    		and $t2, $t2, $t3
    		beq $t2, $t3, toggleFlag_hasNotBeenRevealed_hasFlag
    		j toggleFlag_hasNotBeenRevealed_hasNoFlag
    		
    		toggleFlag_hasNotBeenRevealed_hasFlag:
    		
    			lb $t2, ($t9)
    			li $t3, 111
    			and $t2, $t2, $t3
    			sb $t2 ($t9)
    			
    			lw $t0, cursor_row
    			lw $t1, cursor_col
    			move $a0, $t0
    			move $a1, $t1
    			li $a2, 0
    			li $a3, 7
    			li $t2, 11
    			
    			addi $sp, $sp, -8
    			sw $t2, ($sp)
    			sw $ra, 4($sp)
    			jal set_cell
    			lw $t2, ($sp)
    			lw $ra, 4($sp)
    			addi $sp, $sp, 8
    			
    			j success_perform_action
    			
    		
    		toggleFlag_hasNotBeenRevealed_hasNoFlag:
    		
    			lb $t2, ($t9)
    			li $t3, 16
    			or $t2, $t2, $t3
    			sb $t2 ($t9)
    			
    			lw $t0, cursor_row
    			lw $t1, cursor_col
    			move $a0, $t0
    			move $a1, $t1
    			li $a2, 'f'
    			li $a3, 12
    			li $t2, 11
    			
    			addi $sp, $sp, -8
    			sw $t2, ($sp)
    			sw $ra, 4($sp)
    			jal set_cell
    			lw $t2, ($sp)
    			lw $ra, 4($sp)
    			addi $sp, $sp, 8
    			
    			j success_perform_action
    
    
    error_perform_action:
    
    li $v0, -1
    jr $ra
    
    success_perform_action:
    
    li $v0, 0
    jr $ra

game_status:
    
    #a0 has the cells array
    move $t0, $a0
    li $t1, 100
    gamestatus_checkloss:
    	beqz $t1, gamestatus_checkwin
    	addi $t1, $t1, -1 #decrement counter
    	lb $t2, ($t0) #get the byte
    	#must check if the byte is a revealed bomb
    	li $t3, 96
    	and $t2, $t2, $t3
    	beq $t2, $t3, checkloss_loss
    	addi $t0, $t0, 1
    	j gamestatus_checkloss
    	
    	checkloss_notloss:
    	li $v0, 0
    	jr $ra
    	
    	checkloss_loss:
    	li $v0, -1
    	jr $ra
    	
   
    gamestatus_checkwin:
    move $t0, $a0
    li $t1, 100
    	
    	checkwin_loop:
    	beqz $t1, gamestatus_endcheckwinloop_good
    	addi $t1, $t1, -1
    	lb $t2, ($t0)
    	li $t3, 32
    	li $t4, 16
    	and $t2, $t2, $t4
    	beq $t2, $t4, gamestatus_checkFlag
    	lb $t2, ($t0)
    	and $t2, $t2, $t3
    	beq $t2, $t3, gamestatus_checkBomb
	addi $t0, $t0, 1
	j checkwin_loop 
    	
    	gamestatus_checkFlag:
    	
    		lb $t2, ($t0)
    		and $t2, $t2, $t3
    		bne $t2, $t3, gamestatus_endcheckwinloop_bad
    		addi $t0, $t0, 1
    		j checkwin_loop
    		
    	gamestatus_checkBomb:
    	
    		lb $t2, ($t0)
    		and $t2, $t2, $t4
    		bne $t2, $t3, gamestatus_endcheckwinloop_bad
    		addi $t0, $t0, 1
    		j checkwin_loop
    		
    	gamestatus_endcheckwinloop_good:
    	
    		li $v0, 1
    		jr $ra
    		
    	gamestatus_endcheckwinloop_bad:
    	
    		li $v0, 0
    		jr $ra
   

search_cells:
    
    #a0 = cells array
    #a1 = cursor row
    #a2 = cursor col
    move $fp, $sp #moves the address of sp to the fp, this is used as a condition for the while loop
    addi $sp, $sp, -4
    sw $a1, ($sp)
    addi $sp, $sp, -4
    sw $a2, ($sp)
    
    
    search_cells_loop:
    	li $t0, 10 #num of cols
   	li $t1, 2 #amount per cell for the MMIO (for the reveal part)
    	li $t3, 16 #isFlag()
    	li $t4, 15 #getNumber()
    	li $t5, 64 #isRevealed()
    	
    	beq $fp, $sp, end_search_cells_loop
    	lw $a2, ($sp) #has the col
    	addi $sp, $sp, 4
    	lw $a1, ($sp) #has the row
    	addi $sp, $sp, 4
    	
    	mul $t2, $a1, $t0 # i * num_cols
    	add $t2, $t2, $a2 #add the j
    	add $t2, $t2, $a0 #must keep this perserved!!!!!
    	
    	lb $t7, ($t2) #get the byte
    	and $t6, $t7, $t3 #get the flag bit
    	beq $t6, $t3, search_cells_loop_checksurrounding
    	
    	#we must reveal where the cursor is currently at
    	
    	and $t6, $t7, $t4 #gets the numbers (last 4 bits)
    	beqz $t6, search_cells_loop_revealEmpty
    	j search_cells_loop_revealNumber
    	
    	search_cells_loop_revealEmpty:
    	
    		addi $sp, $sp, -24
    		li $t6, 0 #black bg
    		sw $t6, ($sp)
    		sw $a1, 4($sp)
    		sw $a2, 8($sp)
    		sw $ra, 12($sp)
    		sw $t2, 16($sp)
    		sw $a0, 20($sp) #holds the bg argument
    		
    		move $a0, $a1
    		move $a1, $a2
    		#this moves the row and cols
    		li $a2, 0 #black bg
    		li $a3, 15 #bright magenta
    		
    		jal set_cell
    		
    		lw $t6, ($sp)
    		lw $a1, 4($sp)
    		lw $a2, 8($sp)
    		lw $ra, 12($sp)
    		lw $t2, 16($sp)
    		lw $a0, 20($sp)
    		addi $sp, $sp, 24
    		
    		lb $t0, ($t2)
    		ori $t0, $t0, 64
    		sb $t0, ($t2)
    		
    		li $t0, 10 #num of cols
   		li $t1, 2 #amount per cell for the MMIO (for the reveal part)
    		li $t3, 16 #isFlag()
    		li $t4, 15 #getNumber()
    		li $t5, 64 #isRevealed()
    		
    		j search_cells_loop_checksurrounding
    		
    	search_cells_loop_revealNumber:
    		
    		addi $sp, $sp, -24
    		li $t7, 0 #black bg
    		sw $t7, ($sp)
    		sw $a1, 4($sp)
    		sw $a2, 8($sp)
    		sw $ra, 12($sp)
    		sw $t2, 16($sp)
    		sw $a0, 20($sp) #holds the bg argument
    		
    		move $a0, $a1
    		move $a1, $a2
    		#this moves the row and cols
    		addi $a2, $t6, 48 #adds '0' to the number and passes it in
    		li $a3, 13 #bright magenta
    		
    		jal set_cell
    		
    		lw $t7, ($sp)
    		lw $a1, 4($sp)
    		lw $a2, 8($sp)
    		lw $ra, 12($sp)
    		lw $t2, 16($sp)
    		lw $a0, 20($sp)
    		addi $sp, $sp, 24
    		
    		lb $t0, ($t2)
    		ori $t0, $t0, 64
    		sb $t0, ($t2)
    		
    		li $t0, 10 #num of cols
   		li $t1, 2 #amount per cell for the MMIO (for the reveal part)
    		li $t3, 16 #isFlag()
    		li $t4, 15 #getNumber()
    		li $t5, 64 #isRevealed()
    		
    		j search_cells_loop_checksurrounding
    		
    		search_cells_loop_checksurrounding:
    		
    			#t2 has the address in the cells array
    			lb $t7, ($t2) #get the byte again to check
    			and $t6, $t7, $t4 #get the last 4 bits to get the number
    			beqz $t6, search_cells_loop_checksurrounding_f1
    			j search_cells_loop
    			
    			
    				search_cells_loop_checksurrounding_f1:
    				li $t0, 10
				li $t5, 64
				li $t3, 16
				
    				move $t6, $a1 #will hold the row
    				addi $t6, $t6, 1
    				bge $t6, $t0,  search_cells_loop_checksurrounding_f2 #row + 1 < 10
    				move $t6, $t2 #move the address to t6
    				addi $t6, $t6, 10 #cell[row+1][col]
    				lb $t7, ($t6) #get this new byte, must check if it is hidden
    				and $t7, $t7, $t5 #and it with 64 to get the reveal bit
    				bnez $t7, search_cells_loop_checksurrounding_f2
    				lb $t7, ($t6) #get the byte, must make sure its not a flag
    				and $t7, $t7, $t3 #check if it is a flag by getting the flag bit
    				bnez $t7, search_cells_loop_checksurrounding_f2
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				addi $t6, $t6, 1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				sw $a2, ($sp)
    				#pushes row+1 and col onto the stack
    				j search_cells_loop_checksurrounding_f2
    				
    			search_cells_loop_checksurrounding_f2:
    			
    			
    				move $t6, $a2 #will hold the col
    				addi $t6, $t6, 1
    				bge $t6, $t0, search_cells_loop_checksurrounding_f3 #col + 1 < 10
    				move $t6, $t2 #move the address to t6
    				addi $t6, $t6, 1 #cell[row][col+1]
    				lb $t7, ($t6) #get the byte check if it is hidden
    				and $t7, $t7, $t5 #and it with 64 and get the reveal bit
    				bnez $t7, search_cells_loop_checksurrounding_f3
    				lb $t7, ($t6) #get the byte again we will need ot check if its not a flag
    				and $t7, $t7, $t3 #and it with flag to get flag bit
    				bnez $t7, search_cells_loop_checksurrounding_f3
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				move $t6, $a2
    				addi $t6, $t6, 1
    				sw $t6, ($sp)
    				#pushes the row and col+1 onto the stack
    				j search_cells_loop_checksurrounding_f3
    			
	
    			search_cells_loop_checksurrounding_f3:
    			
    				move $t6, $a1 #will hold the row
    				addi $t6, $t6, -1
    				bltz $t6, search_cells_loop_checksurrounding_f4
    				move $t6, $t2 #move the address to t6
    				addi $t6, $t6, -10
    				lb $t7, ($t6) #get the byte
    				and $t7, $t7, $t5 #and it with 64 and get the reveal bit
    				bnez $t7, search_cells_loop_checksurrounding_f4
    				lb $t7, ($t6)
    				and $t7, $t7, $t3
    				bnez $t7, search_cells_loop_checksurrounding_f4
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				addi $t6, $t6, -1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				move $t6, $a2
    				sw $t6, ($sp)
    				j search_cells_loop_checksurrounding_f4
    				
    				
    			search_cells_loop_checksurrounding_f4:
    			
    				move $t6, $a2 #will hold the col
    				addi $t6, $t6, -1
    				bltz $t6, search_cells_loop_checksurrounding_f5 #col -  1 >= 0
    				move $t6, $t2 #move the address to t6
    				addi $t6, $t6, -1 #cell[row][col-1]
    				lb $t7, ($t6) #get the byte check if it is hidden
    				and $t7, $t7, $t5 #and it with 64 and get the reveal bit
    				bnez $t7, search_cells_loop_checksurrounding_f5
    				lb $t7, ($t6) #get the byte again we will need ot check if its not a flag
    				and $t7, $t7, $t3 #and it with flag to get flag bit
    				bnez $t7, search_cells_loop_checksurrounding_f5
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				move $t6, $a2
    				addi $t6, $t6, -1
    				sw $t6, ($sp)
    				#pushes the row and col+1 onto the stack
    				j search_cells_loop_checksurrounding_f5
    				
    				
    				
    			search_cells_loop_checksurrounding_f5:
    			
    				move $t6, $a1 #will hold the row
    				addi $t6, $t6, -1
    				bltz $t6, search_cells_loop_checksurrounding_f6 #row - 1 >= 0
    				
    				move $t6, $a2 #will hold the col
    				addi $t6, $t6, -1
    				bltz $t6, search_cells_loop_checksurrounding_f6 #col - 1 >= 0
    				
    				move $t6, $t2 #hold the address to t6
    				addi $t6, $t6, -11
    				lb $t7, ($t6) #get the byte upperleft of the previous
    				and $t7, $t7, $t5 #and it with 64 and get the reveal bit
    				bnez $t7, search_cells_loop_checksurrounding_f6
    				
    				lb $t7, ($t6) #get the byte again to check if it is a flag
    				and $t7, $t7, $t3 #and it with the flag num to get the flag bit
    				bnez $t7, search_cells_loop_checksurrounding_f6
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				addi $t6, $t6, -1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				move $t6, $a2
    				addi $t6, $t6, -1
    				sw $t6, ($sp)
    				
    				j search_cells_loop_checksurrounding_f6	
    			
    			search_cells_loop_checksurrounding_f6:
    			
    				move $t6, $a1 #will hold the row
    				addi $t6, $t6, -1
    				bltz $t6, search_cells_loop_checksurrounding_f7 #row - 1 >= 0
    				
    				move $t6, $a2 #will hold the col
    				addi $t6, $t6, 1
    				bge $t6, $t0, search_cells_loop_checksurrounding_f7 #col - 1 >= 0
    				
    				move $t6, $t2 #hold the address to t6
    				addi $t6, $t6, -9
    				lb $t7, ($t6) #get the byte upperleft of the previous
    				and $t7, $t7, $t5 #and it with 64 and get the reveal bit
    				bnez $t7, search_cells_loop_checksurrounding_f7
    				
    				lb $t7, ($t6) #get the byte again to check if it is a flag
    				and $t7, $t7, $t3 #and it with the flag num to get the flag bit
    				bnez $t7, search_cells_loop_checksurrounding_f7
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				addi $t6, $t6, -1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				move $t6, $a2
    				addi $t6, $t6, 1
    				sw $t6, ($sp)
    				
    				j search_cells_loop_checksurrounding_f7	
    			
    			search_cells_loop_checksurrounding_f7:
    			
    				move $t6, $a1 #will hold the row
    				addi $t6, $t6, 1
    				bge $t6, $t0, search_cells_loop_checksurrounding_f8 #row + 1 < 10
    				
    				move $t6, $a2 #will hold the col
    				addi $t6, $t6, -1
    				bltz $t6, search_cells_loop_checksurrounding_f8 #col - 1 >= 0
    				
    				move $t6, $t2 #hold the address to t6
    				addi $t6, $t6, 9
    				lb $t7, ($t6) #get the byte upperleft of the previous
    				and $t7, $t7, $t5 #and it with 64 and get the reveal bit
    				bnez $t7, search_cells_loop_checksurrounding_f8
    				
    				lb $t7, ($t6) #get the byte again to check if it is a flag
    				and $t7, $t7, $t3 #and it with the flag num to get the flag bit
    				bnez $t7, search_cells_loop_checksurrounding_f8
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				addi $t6, $t6, 1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				move $t6, $a2
    				addi $t6, $t6, -1
    				sw $t6, ($sp)
    				
    				j search_cells_loop_checksurrounding_f8
    			
    			search_cells_loop_checksurrounding_f8:
    			
    				move $t6, $a1 #will hold the row
    				addi $t6, $t6, 1
    				bge $t6, $t0, search_cells_loop #row - 1 >= 0
    				
    				move $t6, $a2 #will hold the col
    				addi $t6, $t6, 1
    				bge $t6, $t0, search_cells_loop #col - 1 >= 0
    				
    				move $t6, $t2 #hold the address to t6
    				addi $t6, $t6, 11
    				lb $t7, ($t6) #get the byte upperleft of the previous
    				and $t7, $t7, $t5 #and it with 64 and get the reveal bit
    				bnez $t7, search_cells_loop
    				
    				lb $t7, ($t6) #get the byte again to check if it is a flag
    				and $t7, $t7, $t3 #and it with the flag num to get the flag bit
    				bnez $t7, search_cells_loop
    				
    				addi $sp, $sp, -4
    				move $t6, $a1
    				addi $t6, $t6, 1
    				sw $t6, ($sp)
    				addi $sp, $sp, -4
    				move $t6, $a2
    				addi $t6, $t6, 1
    				sw $t6, ($sp)
    				
    				j search_cells_loop
    			
    				
    				
    			
    			
    			
    				
    			
    			
    				
    			
    			
    			
    			
    	
    	
    end_search_cells_loop:
    jr $ra


.data
.align 2  # Align next items to word boundary
cursor_row: .word -1
cursor_col: .word -1
starting_address: .word 0xffff0000
ending_address: .word 0xffff00c7
buffer: .space 1


