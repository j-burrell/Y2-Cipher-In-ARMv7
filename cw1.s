@script:      cw1.s
@description: Simple cipher program that takes 3 inputs, program mode, 0 or 1 (encrypt/descrypt), key1 and key2. Outputs the enciphered/deciphered text to STDOUT.
@author:      Buzz Embley-Riches & James Burrel.
@date:        07/09/2019

.data
.balign 4
coprimeError: .asciz "Key lengths are not co-prime."
.text
.balign 4
.global main


@stringLength C code
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@int stringLength(char *string){
@
@    int count = 0; //Used to count each character in the string.
@    while (string[count] != '\0') //While not the end of the string, finds end of file character.
@        count++; //Increment counter
@
@    return count; //Return length
@}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@Takes a string variable stored in r0, as an argument.
@Variable Mapping:
@r0 will initially hold string, then be moved to r1.
@r0 will hold count.
stringLength:
	PUSH {r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,lr}

	@R0 will store the variable named string in the C code.
	MOV r1, r0 @Move the string stored in r0 to r1.

	LDRB r2, [r1] @Load the first byte of the string, this will be the first character
				  @string[count] in the C code.

	MOV r0, #0 @Set the initial count to 0, count in C code.

	loopStringLength: @Acts as while loop in C code.

		CMP r2, #0 @Compares first character to a NULL character, end of string.
		BEQ exitStringLength @if NULL character found, exit while loop.
		ADD r0, r0, #1 @Add 1 to our counter, count++ in C code.
		LDRB r2, [r1,r0] @Load next byte of the string, with an offset of the counter.
						 @Loads next character in the string.

		b loopStringLength @Loop back to the start of the while loop.

	exitStringLength: @Looped through whole string, exit with count stored in R0.
	POP {r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,lr}
	BX lr


@characterFormatter C code
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@char characterFormatter(char character){
@    int asciiVal = character; //Set the character paramater to a new int variable
@
@	//Condition1
@    if (asciiVal > 96 && asciiVal < 123){ //If the asciiVal is between lowercase a and z then.
@        return character; //Return the character, it is already formatted.
@        }
@
@	//Condition2
@    else if (asciiVal > 64 && asciiVal < 91){/If the asciiVal is between upercase A and Z then.
@
@        character += 32; //Add 32 to the asciiVal to make it lowercase then.
@        return character; //Return the formatted character.
@        }
@
@	//Condition3
@    else{ //If neither of the above conditions are met, the character is invalid.
@        character = NULL; //Return a null character, this is handled in main.
@        return character;
@
@    }
@}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@Takes a character stored in r0, from getChar as an argument.
@Variable mapping:
@r0 will hold asciiVal.
characterFormatter:

	PUSH {r1,r2,r3,lr}
	@R0 == character passed from arguemnts, asciiVal variable in C code.

	@First part of Condition1 in C code.
	CMP r0, #96 @Compares the asciiVal to 96, this is the start of Condition1 in C code.
	BGT CFIF2 @If the value is greater than 96, continue with Condition1 in C code.
	b CFelse @If asciiVal is not greater than 96, branch to Condition2 in C code.

	CFIF2: @Second part of Condition1.
		CMP r0, #123 @Compare asciiVal in C code, to 123.
		BLT CFIF3 @If the value is less than 123, continue with Condition1 in C code.

	CFIF3: @return part of Condition1.
		b CFreturn @Return the asciiVal, as it is already formatted.

	@First part of Condition2 in C code.
	CFelse:
		CMP r0, #64 @Compare the asciiVal to 64.
		BGT CFIF4 @If the value is greater than 64, continue with Condition2.
		b CFelse2 @If the value is not greater than 64, branch to Condition3.

	@Second part of Condition2.
	CFIF4:
		CMP r0, #91 @Compare asciiVal with 91.
		BLT CFIF5 @If asciiVal is less than 91, continue with Condition2 in C code.

	@return part of Condition2.
	CFIF5:
		ADD r0, r0,#32 @Add 32 to asciiVal, this will make the character go from uppercase to lowercase.
		b CFreturn @return the formatted character.

	@Condition3 in C code.
	@asciiVal is not in between acceptable ranges, so cant be formatted and is invalid.
	CFelse2:
		MOV r0, #-2 @set the return value to -2, this is handled in main.
		b CFreturn @return the value.

	CFreturn:

		POP {r1,r2,r3,lr}
		BX lr




@encryptChar C code.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@char encryptChar(char character, char key){
@
@        char characterAlph = (character - 96); //-96 to get the alphabet numerical value of the character.
@        char keyAlph = (key - 96); //-96 to get the alphabet numerical value of the key.
@        char encyptedChar; //Create empty char for the return value.
@
@
@		//Circular ceaser encryption
@		//If the character will end up going above 26, or below 1, then we handle if by wrapping it around.
@		//Add 96 back to the return character to get it back into ASCII.
@		//ENCRYPTION_CONDITION = ((characterAlph - keyAlph) + 2)
@
@        if (((characterAlph - keyAlph) + 2) > 26) { //if ENCRYPTION_CONDITION is in the upper bound.
@            encyptedChar = (((characterAlph - keyAlph) + 2) - 26) + 96;
@        }
@
@
@		else if ((((characterAlph - keyAlph) + 2) < 1)) { //if ENCRYPTION_CONDITION is in the lower bound.
@            encyptedChar = (((characterAlph - keyAlph) + 2) + 26) + 96;
@
@        }
@
@
@		else { //if ENCRYPTION_CONDITION is neither of the above, just add a shift of 2 as no wrap is needed.
@            encyptedChar = ((characterAlph - keyAlph) + 2) + 96;
@
@        }
@
@	//Return encrypted character.
@    return encyptedChar;
@}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@Takes 2 paramaters, character char in r0, and the key char in r1.
@Variable mapping:
@r0 = characterAlph
@r1 = keyAlph
@r3 = encryptedChar
encryptChar:
	PUSH {r1, r2,r3, r4,r5, lr}

	SUB r0, r0, #96 @characterAlph in C code, gets Alphabet numerical value.
	SUB r1, r1, #96 @keyAlph in C code, gets Alphabet numerical value.

	@These 2 lines are equal to "(characterAlph - keyAlph) + 2)" in C code.
	@Used for comparisons for the circual encryption.
	@R3 will store our, "ENCRYPTION_CONDITION" for ease in comments, used in the if statements in C code.
	SUB r3, r0, r1
	ADD r3, r3, #2

	@R3 will act as our encryptedChar in our C code.
	@Compare ENCRYPTION_CONDITION against 26, this is our upper range, the first IF in our C code.
	CMP r3, #26

	BGT ECIF @If greater than 26, branch to our first if in our c Code.
	b ECnext @if not, go to second if in our C code.


	ECIF: @Encrypt the character, add the shift to r3.
		ADD r3, r3, #70 @Adding 96, then subtracting 26 = adding 70 in C code
	b ECreturn @Go to our return branch.

	ECnext: @checks second if statement in our C code, lower bound.
		CMP r3, #1 @Compares r3 to 1.
		BLT ECIF2 @If the value is less, branch to the second if in our C code.

	b ECelse @If not the above, character does not need to handle wrap, go to our else in C code.

	ECIF2: @Encrypt the character, add the shift to r3.
		ADD r3, r3, #122 @Adding 96, then adding 26 = adding 122
		b ECreturn @Go to our return branch.


	ECelse: @No shift needed, encrypt by normal shift, final else in C code.
		ADD r3,r3,#96


	ECreturn: @return encryptChar in C code.
		MOV r0, r3 @Move our encryptChar to r0, for output.

		POP {r1, r2,r3, r4, r5,lr}
		BX lr




@decryptChar in C code.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@char decryptChar(char character, char key){
@
@    char characterAlph = (character - 96); //-96 to get the alphabet numerical value of the character.
@    char keyAlph = (key - 96); //-96 to get the alphabet numerical value of the key.
@    char decryptedChar; //Create empty char for the return value.
@
@
@	//Circular ceaser encryption
@	//If the character will end up going above 26, or below 1, then we handle if by wrapping it around.
@	//Add 96 back to the return character to get it back into ASCII.
@	//DECRYPTION_CONDITION = ((characterAlph + keyAlph) - 2)
@
@    if(((characterAlph + keyAlph) - 2) < 1){ //if DECRYPTION_CONDITION is in the lower bound.
@        decryptedChar = (((characterAlph + keyAlph) - 2) + 26) + 96;
@    }
@
@	else if (((characterAlph + keyAlph) - 2) > 26){ //if DECRYPTION_CONDITION is in the upper bound.
@        decryptedChar = (((characterAlph + keyAlph) - 2) - 26) + 96;
@    }
@
@    else{ //if DECRYPTION_CONDITION is neither of the above, just add a shift of -2 as no wrap is needed.
@        decryptedChar = ((characterAlph + keyAlph) - 2) + 96;
@    }
@
@	//Return encrypted character.
@    return decryptedChar;
@}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@Takes 2 paramaters, character char in r0, and the key char in r1.
@Variable mapping:
@r0 = characterAlph
@r1 = keyAlph
@r3 = decryptedChar
decryptChar:
	PUSH {r1, r2, r3, r4, r5, lr}

	SUB r0, r0, #96 @characterAlph in C code, gets Alphabet numerical value.
	SUB r1, r1, #96 @keyAlph in C code, gets Alphabet numerical value.

	@These 2 lines are equal to "(characterAlph + keyAlph) - 2)" in C code.
	@Used for comparisons for the circual encryption.
	@R3 will store our, "DECRYPTION_CONDITION" for ease in comments, used in the if statements in C code.
	ADD r3, r0, r1
	SUB r3, r3, #2

	@R3 will act as our encryptedChar in our C code.
	@Compare DECRYPTION_CONDITION against 1, this is our lower range, the first IF in our C code.
	CMP r3, #1

	BLT DCif1 @If less than 1, branch to our first if in our c Code.
	B DCnext @if not, go to second if in our C code.

	DCif1: @Decrypt the character, add the shift to r3.
		ADD r3, r3, #122 @Adding 26 and then adding 96 = adding 122 in C code

	B DCreturn @Go to our return branch.

	DCnext: @checks second if statement in our C code, upper bound.
		CMP r3, #26 @compares r3 to #26
		BGT DCif2 @If the value is less, branch to the second if in our C code.

	B DCelse @If not the above, character does not need to handle wrap, go to our else in C code.

	DCif2: @Decrypt the character, add the shift to r3.
		ADD r3, r3, #70 @Adding 96, then subtracting 26 = adding 70 in C code.
		B DCreturn @Go to our return branch.

	DCelse:
		ADD r3, r3, #96 @No shift needed, encrypt by normal shift, final else in C code.

	@return Decrypted character.
	DCreturn:

		MOV r0, r3 @Move our encryptChar to r0, for output.

		POP {r1, r2, r3,r4 ,r5, lr}
		BX lr




@coprimeCheck in C code
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@int coprimeCheck(char *keystring1, char *keystring2){
@
@    int k1 = stringLength(keystring1); //Get key lengths
@    int k2 = stringLength(keystring2);
@
@    while(k1 != k2){ //Euclid gcd algorithm using subtraction.
@
@        if(k1 > k2){
@
@            k1 = k1 - k2;
@
@        }
@        else{
@            k2 = k2 - k1;
@        }
@    }
@
@    if(k1 == 1){
@
@        return 1; //If coprime return 1.
@
@    }
@    else{
@
@        return 0; //If not coprime return 0.
@
@    }
@
@}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@Takes 2 paramaters, first key in r0, and second key in r1.
@Variable mapping:
@r0 = keyString1
@r1 = keyString2
@r4 = k1
@r5 = k2
coprimeCheck:
	PUSH {r4,r5,r6, lr}

	@r0 will store KeyString1 in C code.
	@r1 will store KeyString2 in C code.

	@Pass r0 to our stringLength function, will return the length of the key in r0.
	BL stringLength

	@Copy the output of r0 to r4.
	MOV r4, r0 @k1 in c code. Length of key1.

	@Move r1 to r0, so stringLength can be called on the second key.
	MOV r0, r1

	@Pass the new r0 to our stringLength function, will return the length of the key in r0.
	BL stringLength

	@Copy the output of r0 to r4
	MOV r5, r0 @k2 in c code. Length of key2.

	@Compare the lengths of k1, and k2 in c Code.
	CMP r4, r5

	@Acts as the while loop in the C code.
	BNE loop1 @If they are not equal, execute the code in the while loop in our c Code.

	loop1:
		@Compare the lengths of k1, and k2 in c Code.
		CMP r4, r5

		@If r4 (k1),greater than r5(k2), subtract k2 from k1 and store in k1 in C code.
		SUBGT r4, r4, r5

		@If r4 less than r5, subtract r4 from r5 and store in r5.
		SUBLT r5, r5, r4

		@If they are equal, continue to the second part of the gcd algorithm.
		BEQ continue

		@if not, loop in while again.
		b loop1


	continue:
		@Compare r4 (k1) to 1.
		CMP r4, #1

		@If equal, we need to return the balue of 1 in branch CCIF2. values are coprime.
		BEQ CCIF2

		@else
		b CCELSE2

	@Stores the value of 1 in r0. 2 keys are coprime.
	CCIF2:
		MOV r0, #1
		b CCreturn

	@Stores the value of 0 in r0. 2 keys are NOT coprime.
	CCELSE2:
		MOV r0, #0

	@return r0, coprime result.
	CCreturn:
		POP {r4, r5, r6, lr}
		BX lr






@main in C code.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@int main() {
@
@
@    char *key = "lock"; //[r1, #8]
@    char *key2 = "key"; //[r1, #12]
@    int programMode = 0; //[r1, #4]
@
@    if (coprimeCheck(key,key2)==1) { //If the 2 keys are co prime
@
@        int key1Length = stringLength(key); //get the length of the first key.
@        int key2Length = stringLength(key2); //get the length of the second key.
@
@        FILE *fp; //Create file pointer.
@        int c; //Create character.
@
@		//Open file
@        fp = fopen("C:\\Users\\Buzz\\Desktop\\coursework1\\message.txt", "r");
@
@		//If file doesnt exist
@        if (fp == NULL) {
@            printf("error");
@        }
@
@        // this while-statement assigns into c, and then checks against EOF:
@        int indexKey1 = 0;
@        int indexKey2 = 0;
@        while ((c = fgetc(fp)) != EOF) {
@
@            char character = characterFormatter(c); //Current character we are looking at in file.
@
@            if (character == NULL) {
@                //EOF
@                printf("");
@            }
@            else {
@                if (programMode == 0) { //Encrypt mode
@                    char encryptedChar = encryptChar(character, key[indexKey1]);
@
@                    encryptedChar = encryptChar(encryptedChar, key2[indexKey2]);
@                    putchar(encryptedChar); //Output encrypted character.
@                } else { //Decrypt mode.
@                    char decryptedChar = decryptChar(character, key[indexKey1]);
@
@                    decryptedChar = decryptChar(decryptedChar, key2[indexKey2]);
@                    putchar(decryptedChar); //output decrypted character
@                }
@
@
@				//INDEX_COUNTER section
@                //Count through the characters in each key.
@                if (indexKey1 == (key1Length - 1)) {
@                    indexKey1 = 0;
@                } else {
@                    indexKey1 += 1;
@                }
@                if (indexKey2 == (key2Length - 1)) {
@                    indexKey2 = 0;
@                } else {
@                    indexKey2 += 1;
@                }
@            }
@        }
@    }
@    else{
@        printf("Key lengths are not co-prime.");
@    }
@
@    return 0;
@}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@Variable Mapping from command line arguments:
@r0 = amounts, [r1, #4] @program mode, [r1, #8] @keystring1, [r1, #12] @keystring2
@r5 = program mode
@r6 = keyString1
@r8 = keyString2
@r9 = "Key lengths are not co-prime."
@r10 = indexKey1
@r11 = indexKey2
main:
	PUSH {r4,lr}
	LDR r4, [r1, #4] @ programMode in C code.
	LDRB r5, [r4, #0] @Gets the first character which will be a 0 or 1.
	SUB r5, r5, #48  @Converts the above into a decimal value.


	LDR r6, [r1, #8] @keystring1 in C code.

	LDR r8, [r1, #12] @keystring2 in C code.

	LDR r9, =coprimeError @Load the coprime error message into r9.


	LDR r0, [r1, #8] @ Loads key from C code into r0.
	LDR r1, [r1, #12] @ Loads key2 from C code into r1.

	MOV r10, #0 @Indexkey1 in C code. This is a counter for the first keys index.
	MOV r11, #0 @IndexKey2 in C code. This is a counter for the second keys index.

	@Call coPrime check with r0 and r1 as arguemnts. key and key2 in C code.
	BL coprimeCheck
	@R0 will now hold 1 if the 2 values are coprime and 0 if they are not.

	@Compare r0, output of coprime with 1.
	CMP r0, #1

	@If they are coprime, we continue.
	BEQ run

	@If they are not coprime we branch to badexit, else in C code.
	BNE badexit


	run:
		@Get the next character in file, and return it in r0.
		BL getchar

		@Compare the output from r0 with -1, this is the EOF character.
		CMP r0, #-1

		@If it is the end of file, we go to our eof exit branch.
		BEQ eof

		@If they are not equal we continue.
		BNE while


	while:
		@We pass the current character in r0 to our characterFormatter as an argument.
		BL characterFormatter
		@return our formatted character in r0, if it was unformattable it will output -2 (error character).

		@Compare r0 with -2.
		CMP r0, #-2

		@If they are not equal we branch back to run and get the next character as this character is invalid.
		BEQ run

		@If they are not equal we check the program mode.
		BNE programMode

	programMode:
		@r5 still contains our programMode numerical value.
		@Compare this with 0 (encrypt mode)
		CMP r5, #0

		@If 0 then we encrypt.
		BEQ encryptMode

		@If not 0 we decrypt.
		BNE decryptMode


	encryptMode:
		@Load a character of key1 with the correct index in C code here.
		LDRB r1, [r6, r10]

		@Encrypt character stored in r0, with a character in key1 with the correct index in r1.
		BL encryptChar

		@Load a character of key1 with the correct index in C code here.
		LDRB r1, [r8, r11]

		@Encrypt character stored in r0, with a character in key2 with the correct index in r1.
		BL encryptChar

		@Fully encrypted character will be stored in r0.
		@Output encrypted to console with putchar.
		BL putchar

		@Continue to index counter to get the correct index for the next character in the keys.
		B indexCounter

	decryptMode:
		@Load a character of key1 with the correct index in C code here.
		LDRB r1, [r6, r10]

		@Decrypt character stored in r0, with a character in key1 with the correct index in r1.
		BL decryptChar

		@Load a character of key1 with the correct index in C code here.
		LDRB r1, [r8, r11]@r11

		@Decrypt character stored in r0, with a character in key2 with the correct index in r1.
		BL decryptChar

		@Fully decrypted character will be stored in r0.
		@Output decrypted to console with putchar.
		BL putchar

		@Continue to index counter to get the correct index for the next character in the keys.
		B indexCounter

	@This section is the INDEX_COUNTER section in C code.
	indexCounter:

		@Gets the length of key1 in C code and subtracts 1, stores result in r2.
		MOV r0, r6
		BL stringLength
		SUB r2, r0, #1

		@Gets the length of key2 in C code and subtracts 1, stores result in r2.
		MOV r0, r8
		BL stringLength
		SUB r3, r0, #1

		@Compare the current index of key1 with its length-1, due to indexing starting at 0.
		CMP r10, r2

		@If they are equal, set they index back to 0.
		BEQ resetK1

		@If they are not equal, increment the index by 1.
		BNE incrementK1

		resetK1:
			@sets r10, key1 in C code index to 0
			MOV r10, #0

			@Goes to key2 index counter check.
			b keyNextIndex


		incrementK1:
			@Adds 1 to r10, key1 in C code.
			ADD r10, r10, #1

			@Goes to key2 index counter check.
			b keyNextIndex


		keyNextIndex:
			@Compare the current index of key2 with its length-1, due to indexing starting at 0.
			CMP r11, r3

			@If they are equal, set they index back to 0.
			BEQ resetK2

			@If they are not equal, increment the index by 1.
			BNE incrementK2

		resetK2:
			@sets r10, key1 in C code index to 0
			MOV r11, #0

			@Continues to next character in file.
			b out


		incrementK2:
			@Adds 1 to r10, key1 in C code.
			ADD r11, r11, #1

			@Continues to next character in file.
			b out

	out:
		@Loads next character.
		B run


	badexit:
		@Outputs the error message stored in coPrimeError string, as 2 keys are not coprime.
		errorOut:
			@Get first character of error message, uses post indexing to increment.
			LDRB r0, [r9], #1

			@Compares character found to NULL character.
			CMP r0, #0

			@If 0 then message fully outputted, exit program through eof.
			BEQ eof

			@if not 0, then output next character.
			BNE errorNext

		errorNext:
			BL putchar
			b errorOut

	eof:
		@If EOF put 0 in r0 and end.
		MOV r0, #0

	POP {r4,lr}
	BX lr

