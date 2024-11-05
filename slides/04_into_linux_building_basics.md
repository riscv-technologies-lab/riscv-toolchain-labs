---
title: "System building for RISC-V"
date: 2024.05.11
fontsize: 26pt
header-includes: |
    \setmainfont[]{Liberation Serif}
    \setsansfont[]{Liberation Sans}
    \setmonofont[]{Liberation Mono}
---

# Введение

- Что такое вообще Linux в вашем понимании?

. . .

- Операционная система?

. . .

- Стандартные библиотеки, sysroot и набор утилит

. . .

- Компиляторы?

# GNU/Linux Copypasta

![[I'd just like to interject for a moment...](https://www.reddit.com/r/linuxmasterrace/comments/zdxkhs/id_just_like_to_interject_for_a_moment/)](images/name-of-the-os.png)

# GNU/Linux Copypasta

- https://stallman-copypasta.github.io/

- https://www.gnu.org/gnu/incorrect-quotation.en.html

. . .

- https://www.reddit.com/r/copypasta/comments/qh45ht/the_linux/

 <!-- https://www.reddit.com/r/linuxmemes/comments/18nrhgb/well_akshually/ -->

# GNU

- GNU "GNU's Not Unix!"
- Набор открытого софта^[https://www.gnu.org/philosophy/free-sw.en.html] для создания своего дистрибутива
- Лицензия GPL/LGPL

# Распутываем компоненты системы

- `Linux kernel` - ядро операционной системы
- Кросс или нативный^[Нативный тулчейн не обязателен] тулчейн на основе GCC/Clang для C/C++/Fortran/Flang e.t.c.
- Стандартные утилиты GNU Coreutils/Bash. Альтернативна [Busybox](https://busybox.net/)/[Toybox](https://github.com/landley/toybox)

# Железо

Работаем с Lichee Pi 4A: https://sipeed.com/licheepi4a

\bigskip

> Lichee Pi 4A is the Risc-V linux development board using [Lichee Module 4A](http://wiki.sipeed.com/hardware/en/lichee/th1520/lm4a.html)
> core module, its main chip is [TH1520](https://www.t-head.cn/product/yeying), contains 4TOPS@int8 AI NPU,
> supports dual screen 4K resolution display and 4K mipi camera input, dual Gigabit Ethernets and Multiple USB interfaces
> provides enough connections. And there is a Riscv C906 Core for audio decode.

# Разбираемся в уже собранном образе

- Официальный диструбутив на основе Debian: [ссылка](https://wiki.sipeed.com/hardware/en/lichee/th1520/lpi4a/3_images.html).

. . .

- Собран под железо SoC [THEAD1520](https://www.t-head.cn/).
- Кастомные [расширения](https://github.com/XUANTIE-RV/thead-extension-spec)

. . .

- Как можно прогонать без физического устройства?

# qemu-system

- Уже знакомы с userspace эмуляцией [QEMU](https://www.qemu.org/docs/master/user/main.html).

. . .

- Вендор реализует симулятор с поддержкой привелегированных операций и расширений конкретного процессора.
- Позволяет запускать `baremetal` приложения.
- [qemu-system](https://www.qemu.org/docs/master/system/index.html)

# Полезные ссылки

- [Embedded Linux from Scratch in 45 minutes, on RISC-V - Bootlin](https://www.youtube.com/watch?v=cIkTh3Xp3dA&t=1333s)
- [https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html)
