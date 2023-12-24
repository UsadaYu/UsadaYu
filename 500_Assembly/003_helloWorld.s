/**
 * A HelloWorld program written in assembly language
 * @ref https://zhuanlan.zhihu.com/p/388683540
 * 
 * 此汇编用例对应的C代码：
 *  int main() {
 *      printf("Hello World!\n");
 *      return 0;
 *  }
 */

/**
 * 符号.开头的为汇编伪指令，它们实际上不属于ARM指令
 */
.text
    .file   "main.c"                        // .file告诉汇编启动一个新的逻辑文件，这里是main.c，不加""也可以
    .globl  main                            // 从名为main的标签开始执行，若当前文件不存在此标签，那么会从链接到此文件的其它文件中寻找
    .p2align    2                           // 字节对齐方式，表示指令以2^2=4Bytes大小对齐，即2^(p2align)
    .type   main,@function                  // 表示main函数是一个函数类型的符号，确保编译器和链接器识别它，生成正确的代码和符号链接

/**
 * GUN ARM汇编中，以符号:结尾的都会被视为标签(label)
 * 此处，定义一个名称为main的标签，在上述的.type伪指令中，定义了这个标签类型是一个函数。
 * 到此，一个main函数就成功被定义了
 */
main:
/**
 * fp(x29 Frame Pointer)寄存器记录着当前栈底的地址；
 * lr(x30)寄存器记录着当前栈的返回地址，即这个函数调用后，应该返回到哪里。
 * sp(x31 Stack Pointer)寄存器记录着当前栈顶的地址；
 * pc(x32)寄存器记录着当前CPU正在执行的指令；
 * 
 * sub sp, sp, #32
 * 表示在栈上开辟一块全新的栈帧(stack frame)。
 * 栈内存是从高位向低位生长的，所以开辟新的栈帧需要使用减法(sub指令)。
 * 此处，main函数大约需要32Bytes的栈空间来实现HelloWorld；
 * 将sp向下移动空出32Bytes的栈空间用于存放局部变量。
 * 
 * 进程处于main函数时，lr寄存器记录的是main函数返回值的地址；
 * main函数结束后，进程会回到这个lr记录的地址
 * 
 * gdb打印：
 * x29  0x7ffffffa90
 * sp   0x7ffffffa90
 */
    sub sp, sp, #32

/**
 * 为了打印HelloWorld，需要调用printf函数；
 * 每次调用函数都需要开辟一块新的栈帧。
 * 
 * 在执行printf函数时，需要让lr寄存器保存main函数的地址；
 * 所以调用printf之前，需要将当前main函数的lr和fp寄存器(和一些其它需要备份的寄存器)先备份到栈内存上；
 * 备份后，printf函数就可以自由地使用这些寄存器了。
 * 当printf函数执行完毕后，它会通过lr寄存器回到main函数，此时再把备份的数据返还到lr、fp等寄存器即可。
 * 
 * stp x29, x30, [sp, #16]
 * 此处表示将x29、x30存放到sp地址向上偏移16字节处。
 * 这是为了备份fp和lr寄存器的数据。
 * 在ARM64汇编中，以st开头的指令都是将寄存器的值store到内存地址上。
 * stp(store pair)表示将两个寄存器的值保存到内存中；
 * 所以x29存放在sp + #16处；x30存放在sp + #24处
 * 
 * gdb打印：
 * x29  0x7ffffffa90
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70    @ 0x7ffffffa90 - #32 = 0x7ffffffa70
 */
    stp x29, x30, [sp, #16]

/**
 * fp寄存器的数据备份后，就可以修改fp寄存器的值了，将其设置为新栈帧的栈底
 * 
 * add x29, sp, #16
 * 表示将栈顶寄存器的值加上#16然后存储到寄存器x29中，此时fp寄存器就记录了新函数栈帧的栈底地址
 * 
 * gdb打印：
 * x29  0x7ffffffa90
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70
 * 
 * x/32xg $sp           @ 查看sp寄存器向上32字节的内容
 * 0x7ffffffa80:   0x0000007ffffffa90      0x0000007ff7e47ffc
 * 0x7ffffffa70 + #16 = 0x7ffffffa80，
 * 0x7ffffffa80存放x29(0x0000007ffffffa90)；
 * 0x7ffffffa88存放x30(0x0000007ff7e47ffc)
 */
    add x29, sp, #16

/**
 * main函数是有一个返回值的，不出意外就是return 0。
 * 假设有一个函数已经产生了返回值，储存在x8，但是它不急着返回，而是先调用其他函数；
 * 那么x8寄存器中的值也是需要先缓存的。后续会做这一步操作，这里，先假设main函数的返回值为0，即将x8寄存器置为0
 * 
 * mov w8, wzr
 * 表示将w8寄存器寄存器重置为0。wzr即x31，零寄存器。wzr即32bit下对x31的零寄存器引用方式。
 * 这类似于给变量赋一个初值，如int *ptr = NULL
 * 
 * gdb打印：
 * x8   0x105           @ x8(w8)寄存器用于保存函数的返回值
 * x29  0x7ffffffa80    @ 0x7ffffffa70 + #16 = 0x7ffffffa80，
                        @ 栈地址向下增长，以0x7ffffffa80为栈底不会覆盖前面缓存的x29和x30
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70
 */
    mov w8, wzr

/**
 * 上面说过，st开头的指令都是表示将寄存器的值store到内存地址上。
 * 
 * stur wzr, [x29, #-4]
 * 表示将(fp - #4)地址上的32bit内容全部清零。armv8是64bit的，hi3519dv500大概是大端存储，
 * 假设0x7ffffffa78上的内容为0xffffffff ffffffff，那么fp - #4清零32bit后变为0x00000000 ffffffff。
 * 实际上，这条命令用于处理main函数的输入参数，这里main函数输入为空，所以写0，后续也不会用到
 * 
 * gdb打印：
 * x8   0x0
 * 
 * x/8xg 0x7ffffffa70
 * 0x7ffffffa70:   0x0000007ffffffa90      0x0000007ff7e47fc0
 */
    stur    wzr, [x29, #-4]

/**
 * 到此，函数的传参还没有准备，也就是"Hello World!\n"字符串。
 * "Hello World!\n"是一个静态全局字符串，一般已经保存在内存中，只需要查找此字符串的地址即可。
 * 
 * adrp    x0, .L.str
 * adrp指令用于计算和加载一个地址；
 * .L.str是一个标签，通常用于表示一个地址或变量的位置。
 * 这条命令通过adrp指令将.L.str的地址加载到x0寄存器中，x0寄存器可用于传参或保存返回值，这类用作传参。
 * 
 * 注意，这里只是读取了字符串所在页的基地址，不是字符串的具体地址。
 * armv8架构中，需要了解PC相对寻址。
 * armv8架构中，指令的相对偏移地址分为两部分：高位(高21位)和低位(12位)。
 * 寻址时，将高位和低位相加，可以得到真正的绝对地址。
 * adrp指令会将全局标签.L.str的高21位地址储存在寄存器x0中，此时低12位为0。
 * 所以这里仅得到了字符串所在页的基地址
 * 
 * gdb打印：
 * x0   0x6
 * 
 * x/8xg 0x7ffffffa70
 * 0x7ffffffa70:   0x0000007ffffffa90      0x00000000f7e47fc0   @ 0x7ffffffa78的高32bit被清零
 */
    adrp    x0, .L.str

/**
 * 在得到.L.str页的基地址后，需要获取字符串"Hello World!\n"的地址。
 * 
 * add x0, x0, :lo12:.L.str
 * :lo12:是一个伪操作符，用来计算一个符号相对于标签的低12位偏移量。
 * :lo12:.L.str表示计算.L.str标签相对于当前指令所在位置的低12位偏移量。
 * 这条命令将x0寄存器的值与:lo12:.L.str的偏移量相加，并将结果存储回x0寄存器
 * 
 * gdb打印：
 * x0   0x400000
 */
    add x0, x0, :lo12:.L.str

/**
 * printf函数是int类型的，会返回字符串的长度，这个返回值一般也是通过寄存器传递的。
 * 先前x8寄存器中是main函数的返回值，所以要先保存
 * 
 * str w8, [sp, #8]
 * 将x8寄存器中的值储存在sp + #8中
 * 
 * gdb打印：
 * x0   0x400628    @ .L.str标签页地址 + :lo12:
 * 
 * x/8xg $sp
 * 0x7ffffffa70:   0x0000007ffffffa90      0x00000000f7e47fc0
 */
    str w8, [sp, #8]

/**
 * 此时，main函数的lr、fp、x8都已经缓存；
 * printf函数的栈帧也已经开辟，那么就可以调用printf函数了。
 * 关于sp寄存器，不需要缓存，printf函数调用后会自行将sp寄存器恢复；
 * 就像这里main函数一样，开头的sub sp, sp, #32和末尾的add sp, sp, #32完成的就是此操作
 * 
 * bl  printf
 * 调用printf函数，并将当前地址作为返回地址保存在lr(x30)寄存器中
 * 
 * gdb打印：
 * x30  0x7ff7e47ffc
 * 
 * x/8xg $sp
 * 0x7ffffffa70:   0x0000007ffffffa90      0x0000000000000000   @ 存放了main函数的x8
 * 0x7ffffffa80:   0x0000007ffffffa90      0x0000007ff7e47ffc   @ 存放了main函数的fp(x29)和main函数的lr(x30)
 */
    bl  printf

/**
 * printf函数调用完成后，它的返回值会被存储在寄存器x8中，这个返回值可以保留也可以不保留；
 * 因为在此程序中没什么作用，这里将其丢弃，不使用w8寄存器中的内容
 * 
 * ldr w8, [sp, #8]
 * ldr是加载指令(load)，用于将内存中的数据加载到寄存器。
 * 这里表示将sp + #8的内容存恢复储到x8寄存器。
 * 
 * gdb打印：
 * x8   0x40
 * x30  0x4005e8
 */
    ldr w8, [sp, #8]

/**
 * mov w0, w8
 * 将x8寄存器的值移动到x0寄存器，即将x8寄存器中的数据储存到的x0寄存器；
 * 这里x0寄存器用于保存main函数的返回值
 * 
 * gdb打印：
 * x0   0xd
 * x8   0x0
 */
    mov w0, w8

/**
 * 这里，需要恢复fp寄存器和lr寄存器的数据
 * 
 * ldp x29, x30, [sp, #16]
 * ldp指令用于加载一对寄存器的值。
 * 这条命令将sp + #16内存中的内容恢复到fp寄存器和lr寄存器
 * 
 * gdb打印：
 * x0   0x0
 * x29  0x7ffffffa80
 * x30  0x4005e8
 */
    ldp x29, x30, [sp, #16]

/**
 * 归还main函数栈帧内存
 * 
 * add sp, sp, #32
 * 将sp寄存器的值向上偏移32Bytes，归还栈帧内存
 * 
 * gdb打印：
 * x29  0x7ffffffa90
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70
 */
    add sp, sp, #32

/**
 * main函数返回
 * 
 * ret
 * 相当于C语言中的return。
 * main函数的返回值储存在x0寄存器中
 * 
 * gdb打印：
 * sp   0x7ffffffa90
 */
    ret

.Lfunc_end0:
    .size   main, .Lfunc_end0-main
    .type   .L.str,@object
    .section    .rodata.str1.1,"aMS",
.L.str:
    .asciz  "Hello World!\n"            // .asciz和.ascii一样，但每个字符串后面会有一个0字符字节
    .size   .L.str, 14
    .section    ".note.GNU-stack","",@progbits
