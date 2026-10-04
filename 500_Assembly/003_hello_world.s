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
 * 符号.开头的为汇编伪指令，它们实际上不属于 ARM 指令
 */
.text
    .file   "main.c"                        // .file 告诉汇编启动一个新的逻辑文件，这里是 main.c，不加 "" 也可以
    .globl  main                            // 从名为 main 的标签开始执行，若当前文件不存在此标签，那么会从链接到此文件的其它文件中寻找
    .p2align    2                           // 字节对齐方式，表示指令以 2^2=4Bytes 大小对齐，即 2^(p2align)
    .type   main,@function                  // 表示 main 函数是一个函数类型的符号，确保编译器和链接器识别它，生成正确的代码和符号链接

/**
 * GUN ARM 汇编中，以符号:结尾的都会被视为标签（label）
 * 此处，定义一个名称为 main 的标签，在上述的 .type 伪指令中，定义了这个标签类型是一个函数。
 * 到此，一个 main 函数就成功被定义了
 */
main:
/**
 * fp(x29 Frame Pointer) 寄存器记录着当前栈底的地址；
 * lr(x30) 寄存器记录着当前栈的返回地址，即这个函数调用后，应该返回到哪里。
 * sp(x31 Stack Pointer) 寄存器记录着当前栈顶的地址；
 * pc(x32) 寄存器记录着当前 CPU 正在执行的指令；
 * 
 * sub sp, sp, #32
 * 表示在栈上开辟一块全新的栈帧（stack frame）。
 * 栈内存是从高位向低位生长的，所以开辟新的栈帧需要使用减法（sub 指令）。
 * 此处，main 函数大约需要 32Bytes 的栈空间来实现 HelloWorld；
 * 将 sp 向下移动空出 32Bytes 的栈空间用于存放局部变量。
 * 
 * 进程处于 main 函数时，lr 寄存器记录的是 main 函数返回值的地址；
 * main 函数结束后，进程会回到这个 lr 记录的地址
 * 
 * gdb 打印：
 * x29  0x7ffffffa90
 * sp   0x7ffffffa90
 */
    sub sp, sp, #32

/**
 * 为了打印 HelloWorld，需要调用 printf 函数；
 * 每次调用函数都需要开辟一块新的栈帧。
 * 
 * 在执行 printf 函数时，需要让 lr 寄存器保存 main 函数的地址；
 * 所以调用 printf 之前，需要将当前 main 函数的 lr 和 fp 寄存器（和一些其它需要备份的寄存器）先备份到栈内存上；
 * 备份后，printf 函数就可以自由地使用这些寄存器了。
 * 当 printf 函数执行完毕后，它会通过 lr 寄存器回到 main 函数，此时再把备份的数据返还到 lr、fp 等寄存器即可。
 * 
 * stp x29, x30, [sp, #16]
 * 此处表示将 x29、x30 存放到 sp 地址向上偏移 16 字节处。
 * 这是为了备份 fp 和 lr 寄存器的数据。
 * 在 ARM64 汇编中，以 st 开头的指令都是将寄存器的值 store 到内存地址上。
 * stp(store pair) 表示将两个寄存器的值保存到内存中；
 * 所以 x29 存放在 sp + #16 处；x30 存放在 sp + #24 处
 * 
 * gdb 打印：
 * x29  0x7ffffffa90
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70    @ 0x7ffffffa90 - #32 = 0x7ffffffa70
 */
    stp x29, x30, [sp, #16]

/**
 * fp 寄存器的数据备份后，就可以修改 fp 寄存器的值了，将其设置为新栈帧的栈底
 * 
 * add x29, sp, #16
 * 表示将栈顶寄存器的值加上 #16 然后存储到寄存器 x29 中，此时 fp 寄存器就记录了新函数栈帧的栈底地址
 * 
 * gdb 打印：
 * x29  0x7ffffffa90
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70
 * 
 * x/32xg $sp           @ 查看 sp 寄存器向上 32 字节的内容
 * 0x7ffffffa80:   0x0000007ffffffa90      0x0000007ff7e47ffc
 * 0x7ffffffa70 + #16 = 0x7ffffffa80，
 * 0x7ffffffa80 存放 x29(0x0000007ffffffa90)；
 * 0x7ffffffa88 存放 x30(0x0000007ff7e47ffc)
 */
    add x29, sp, #16

/**
 * main 函数是有一个返回值的，不出意外就是 return 0。
 * 假设有一个函数已经产生了返回值，储存在 x8，但是它不急着返回，而是先调用其他函数；
 * 那么 x8 寄存器中的值也是需要先缓存的。后续会做这一步操作，这里，先假设 main 函数的返回值为 0，即将 x8 寄存器置为 0
 * 
 * mov w8, wzr
 * 表示将 w8 寄存器寄存器重置为 0。wzr 即 x31，零寄存器。wzr 即 32bit 下对 x31 的零寄存器引用方式。
 * 这类似于给变量赋一个初值，如 int *ptr = NULL
 * 
 * gdb 打印：
 * x8   0x105           @ x8(w8) 寄存器用于保存函数的返回值
 * x29  0x7ffffffa80    @ 0x7ffffffa70 + #16 = 0x7ffffffa80，
                        @ 栈地址向下增长，以 0x7ffffffa80 为栈底不会覆盖前面缓存的 x29 和 x30
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70
 */
    mov w8, wzr

/**
 * 上面说过，st 开头的指令都是表示将寄存器的值 store 到内存地址上。
 * 
 * stur wzr, [x29, #-4]
 * 表示将 (fp - #4) 地址上的 32bit 内容全部清零。armv8 是 64bit 的，hi3519dv500 大概是大端存储，
 * 假设 0x7ffffffa78 上的内容为 0xffffffff ffffffff，那么 fp - #4 清零 32bit 后变为 0x00000000 ffffffff。
 * 实际上，这条命令用于处理 main 函数的输入参数，这里 main 函数输入为空，所以写 0，后续也不会用到
 * 
 * gdb 打印：
 * x8   0x0
 * 
 * x/8xg 0x7ffffffa70
 * 0x7ffffffa70:   0x0000007ffffffa90      0x0000007ff7e47fc0
 */
    stur    wzr, [x29, #-4]

/**
 * 到此，函数的传参还没有准备，也就是 "Hello World!\n" 字符串。
 * "Hello World!\n" 是一个静态全局字符串，一般已经保存在内存中，只需要查找此字符串的地址即可。
 * 
 * adrp    x0, .L.str
 * adrp 指令用于计算和加载一个地址；
 * .L.str 是一个标签，通常用于表示一个地址或变量的位置。
 * 这条命令通过 adrp 指令将 .L.str 的地址加载到 x0 寄存器中，x0 寄存器可用于传参或保存返回值，这类用作传参。
 * 
 * 注意，这里只是读取了字符串所在页的基地址，不是字符串的具体地址。
 * armv8 架构中，需要了解 PC 相对寻址。
 * armv8 架构中，指令的相对偏移地址分为两部分：高位（高 21 位）和低位（12 位）。
 * 寻址时，将高位和低位相加，可以得到真正的绝对地址。
 * adrp 指令会将全局标签 .L.str 的高 21 位地址储存在寄存器 x0 中，此时低 12 位为 0。
 * 所以这里仅得到了字符串所在页的基地址
 * 
 * gdb 打印：
 * x0   0x6
 * 
 * x/8xg 0x7ffffffa70
 * 0x7ffffffa70:   0x0000007ffffffa90      0x00000000f7e47fc0   @ 0x7ffffffa78的高32bit被清零
 */
    adrp    x0, .L.str

/**
 * 在得到 .L.str 页的基地址后，需要获取字符串 "Hello World!\n" 的地址。
 * 
 * add x0, x0, :lo12:.L.str
 * :lo12: 是一个伪操作符，用来计算一个符号相对于标签的低 12 位偏移量。
 * :lo12:.L.str 表示计算 .L.str 标签相对于当前指令所在位置的低 12 位偏移量。
 * 这条命令将 x0 寄存器的值与 :lo12:.L.str 的偏移量相加，并将结果存储回 x0 寄存器
 * 
 * gdb 打印：
 * x0   0x400000
 */
    add x0, x0, :lo12:.L.str

/**
 * printf 函数是 int 类型的，会返回字符串的长度，这个返回值一般也是通过寄存器传递的。
 * 先前 x8 寄存器中是 main 函数的返回值，所以要先保存
 * 
 * str w8, [sp, #8]
 * 将 x8 寄存器中的值储存在 sp + #8 中
 * 
 * gdb 打印：
 * x0   0x400628    @ .L.str 标签页地址 + :lo12:
 * 
 * x/8xg $sp
 * 0x7ffffffa70:   0x0000007ffffffa90      0x00000000f7e47fc0
 */
    str w8, [sp, #8]

/**
 * 此时，main 函数的 lr、fp、x8 都已经缓存；
 * printf 函数的栈帧也已经开辟，那么就可以调用 printf 函数了。
 * 关于 sp 寄存器，不需要缓存，printf 函数调用后会自行将 sp 寄存器恢复；
 * 就像这里 main 函数一样，开头的 sub sp, sp, #32 和末尾的 add sp, sp, #32 完成的就是此操作
 * 
 * bl  printf
 * 调用 printf 函数，并将当前地址作为返回地址保存在 lr(x30) 寄存器中
 * 
 * gdb 打印：
 * x30  0x7ff7e47ffc
 * 
 * x/8xg $sp
 * 0x7ffffffa70:   0x0000007ffffffa90      0x0000000000000000   @ 存放了 main 函数的 x8
 * 0x7ffffffa80:   0x0000007ffffffa90      0x0000007ff7e47ffc   @ 存放了 main 函数的 fp(x29) 和 main 函数的 lr(x30)
 */
    bl  printf

/**
 * printf 函数调用完成后，它的返回值会被存储在寄存器 x8 中，这个返回值可以保留也可以不保留；
 * 因为在此程序中没什么作用，这里将其丢弃，不使用 w8 寄存器中的内容
 * 
 * ldr w8, [sp, #8]
 * ldr 是加载指令（load），用于将内存中的数据加载到寄存器。
 * 这里表示将 sp + #8 的内容存恢复储到 x8 寄存器。
 * 
 * gdb 打印：
 * x8   0x40
 * x30  0x4005e8
 */
    ldr w8, [sp, #8]

/**
 * mov w0, w8
 * 将 x8 寄存器的值移动到 x0 寄存器，即将 x8 寄存器中的数据储存到的 x0 寄存器；
 * 这里 x0 寄存器用于保存 main 函数的返回值
 * 
 * gdb 打印：
 * x0   0xd
 * x8   0x0
 */
    mov w0, w8

/**
 * 这里，需要恢复 fp 寄存器和 lr 寄存器的数据
 * 
 * ldp x29, x30, [sp, #16]
 * ldp 指令用于加载一对寄存器的值。
 * 这条命令将 sp + #16 内存中的内容恢复到 fp 寄存器和 lr 寄存器
 * 
 * gdb 打印：
 * x0   0x0
 * x29  0x7ffffffa80
 * x30  0x4005e8
 */
    ldp x29, x30, [sp, #16]

/**
 * 归还 main 函数栈帧内存
 * 
 * add sp, sp, #32
 * 将 sp 寄存器的值向上偏移 32Bytes，归还栈帧内存
 * 
 * gdb 打印：
 * x29  0x7ffffffa90
 * x30  0x7ff7e47ffc
 * sp   0x7ffffffa70
 */
    add sp, sp, #32

/**
 * main 函数返回
 * 
 * ret
 * 相当于 C 语言中的 return。
 * main 函数的返回值储存在 x0 寄存器中
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
    .asciz  "Hello World!\n"            // .asciz 和 .ascii 一样，但每个字符串后面会有一个 0 字符字节
    .size   .L.str, 14
    .section    ".note.GNU-stack","",@progbits
