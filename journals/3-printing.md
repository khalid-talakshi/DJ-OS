# Entry 3: Printing to Screen
At this point we have created a bootable image, but it doesn't do anything. It would be nice to actually print stuff to the screen. For now we will print a test string to welcom us to our OS. 

## 16 Bit Printing
To build something basic, we are going to use 16 bit registers in assembly. A list of registers can be found [here](https://www.eecg.utoronto.ca/~amza/www.mindsec.com/files/x86regs.html), including their purpose. For this part we will use the general purpose register `AX`. `AX` can be split up into two 8-bit registers `AH` and `AL` representing the higher and lower order bits of the register. 

## Interrupts
Interrupts are how we tell the CPU that we need to do something important. Imagine you want to print something to the screen, you need to tell the CPU that you want to print to the screen. However the CPU can only handle 1 instructiona at a time. If you were to add it to a queue, it will print but it will take a while. Now imagine our infinite loop is the instruction currently in the CPU pipeline (if you want to learn more about CPU I recommend [this book](https://www.amazon.ca/Computer-Organization-Design-ARM-Architecture-ebook/dp/B01H1DCRRC/ref=sr_1_1?dchild=1&keywords=Computer+Organization+and+design+arm+edition&qid=1620061128&s=books&sr=1-1)). We will never get to print our item to the screen. This is a very high oversimplifcation, but you get the idea, it tells the CPU that you need to display this right now. There are a ton of CPU interrupts for the x86 architecture, but the one we will use is `0x10`. This one is used for video interrupts, which include our display. You can see all the different things this interrupt does at [this site](http://www.ctyme.com/intr/int-10.htm)

## Registers and Printing
Now lets start with our implementation. We will start with trying to print a character. It is important that you know ASCII, but luckily we can pass characters directly to registers. Since we are using 8-bit registers for arguments, we can represent 256 possible options. If you look at this [ascii table](https://www.rapidtables.com/code/text/ascii-table.html), you'll see that we have 128 standard options plus 128 extended options, which adds up to 256 (It's almost as if it was designed this way!). Now going back to the previous site, we can see that there is one interrupt type that gets us into teletype mode. This is how we can display characters to the screen. So in order to print, we set the higher order bits to `0x0e` to represent teletype mode, and the lower level bits to the character to we want to print to the screen. To add items to these registers, we will use `mov <reg>, <val>` to load values into our register. For our example let's print "H":
```armasm
mov ah, 0x0e
mov al, 'H' ; you can also use 0x48
int 0x10
```
Breaking this down we load our arguments into the registers, and then call our interrupt. The interrupt handler then looks in `AH` to see what it should do. It sees `0x0e` and knows to put it in teletype mode and then look in `AL` to see what it should output, 

### Exercies: Print your name

Now that you can print a char, you can print full words to the screen. Try and print your name to the screen. 

# Printing Strings
Its cool that we can print chars, but odds are we want to print longer blocks of texts. How can we do this? Well remember, everything we write ends up in memory. You should also note that if a char takes up one block of memory, a string would take up n blocks, where n is the length of the string. One cool thing about memory is that we can access it like an array. Basically what we can do is load an address up, and then access the item at the address. We then increment our address by 1 and access the next address. Seems complicated? Lets break it down. First we need to load our string in memory. For now we can use a label to represent this:
```armasm
teststring:
    db 'This is a test string`, 0 ; indent not necessary
```
What this does is it creates a series of bytes that represent the string, followed by a null terminator of 0 (in ascii this 0 represents this). This will be important for reading strings. We label it as teststring to give it an address. In our OS our addresses are 16-bit, so we should load the address into a 16 bit register. Since we use `AX` for character printing, lets use `BX`. 
```armasm
mov bx, teststring
```
Now lets create a funciton. We will call this function `printString`. First we will load into `AX` the teletype argument.
```armasm
printString:
    mov al, 0x0e
```
Next we will ues the `cmp` instruction to compare values. Which values will we be comparing? Well we loaded the address of `teststring` into the `BX` register. We can access the item at this register by doing `[bx]`. We will compare this value to our null terminator value of 0. cmp basically sets a value in a register (don't need to know which one right now, just know we won't overwrite any register for now). This value can then be interpreted by a jump instruction. Remember how we used `jmp` to create an infinte loop? This is known as an unconditional jump. No matter what the value in the register is, we jump. We can use conditional jumps, which only jump if the register contains a certain value. We will use the `je` to jump to a label if the values of `[bx]` and `0` are equal. We will define a label `.exit` to return from our function. 
```armasm
printString:
    mov al, 0x0e
    cmp [bx], 0
    je .end
    .end: 
        ret
```
Now if the value is something else, lets print it to the screen. We will do this by creating a `.loop` label above the `cmp` instruction. We also know how to print already, the only difference is that instead of hardcoding a letter we will load the value of `[bx]`. Lets add that code right now.
```armasm
printString:
    mov al, 0x0e
    .loop:
        cmp [bx], 0
        je .end
        mov al, [bx]
        int 0x10
        jmp .loop
    .end: 
        ret
```
You might see a problem with this code. Right now we are printing the value of bx, then going back to loop. We have created a loop, but we haven't changed what bx is pointing to. Thus we have create an infinite loop printing the first character. How can we fix this? We can use the `inc` operator to increment the value fo `bx` by 1. Thus it will point to the next block. 
```armasm
printString:
    mov al, 0x0e
    .loop:
        cmp [bx], 0
        je .end
        mov al, [bx]
        int 0x10
        inc bx
        jmp .loop
    .end:
        ret
```
And boom now we have done it! Running our code now should print "This is a test string". Or will it? Fundamental law of programming states if you create a funciton, you must call it. We can use the `call` keyword above this funciton to call it. 
## Encapsulation
Our boot file is getting big now, and this functionality might be useful for other programs. Let's encapsulate this functionality into its own file. Inside `src` we create a file called `print.asm`. Inside print.asm we will add our printString function as well as our teststring. Inside of boot now we will add an include line to include the print.asm file inside of boot. We will then add the loading of test string into bx here and call the function. This is what boot should look like.
```armasm
%include "print.asm"

mov bx, teststring

call printString

jmp $

times 510-($-$$), db 0
db 0x55, 0xaa
```
Compiling this down and boom we have the ability to print teststring. Go ahead and change it to whatever you want and run it!