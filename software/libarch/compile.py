#!/bin/python3


import argparse
import os
import sys

CC = "riscv64-unknown-elf-gcc "
FLAGS = " -nostdlib -nostartfiles -flto -march=rv32i -mabi=ilp32 -lgcc "
OBJCPY = "riscv64-unknown-elf-objcopy "
AR = "riscv64-unknown-elf-ar"
MEM_SIZE_KB = 8
MEM_SIZE = int((1024 * MEM_SIZE_KB)/4)

def list_sources(path):
    return os.listdir(path)

def glob_sources(path):
    return list([f"\"{path}/{source}\" " for source in list_sources(path)])


def linkfile(libpath):
    return f"\"{libpath}/link.ld\""


def run(cmd):
    print("\n" + cmd + "\n")
    os.system(cmd)


def build_libarch(libpath):
    
    sources = list_sources(f"{libpath}/src/")
    


    run(f"{CC} {FLAGS} \"{libpath}/boot.S\" -o \"{libpath}/boot.o\" -c -T{linkfile(libpath)}")

    for source in sources:
        command = CC + FLAGS + f"-T{linkfile(libpath)} -c -o \"{libpath}/{source}.o\" -I{include_dir(libpath)} \"{libpath}/src/{source}\""
        run(command)

    source_objects = ""
    for source in sources:
        source_objects += f"\"{libpath}/{source}.o\" "
    
    run(f"{AR} rvs \"{libpath}/soft-riscv-libarch.a\" {source_objects}")



def include_dir(libpath):
    return f"\"{libpath}/include\""


def build_target(libpath, targetpath, output):
    sources = glob_sources(f"{targetpath}/src/")
    sources.extend( glob_sources(f"{libpath}/src/").__iter__() )

    libgcc = " \"/usr/lib/gcc/riscv64-unknown-elf/10.2.0/rv32i/ilp32/libgcc.a\""
    command = CC + FLAGS + f"-T{linkfile(libpath)} {' '.join(sources)} -I{include_dir(libpath)} -o\"{output}\" " + libgcc

    run(command)

    #objcopy = f"{OBJCPY} -O verilog --verilog-data-width 4 \"{output}\" \"{output}.vh\""
    objcopy = f"{OBJCPY} -O binary \"{output}\" \"{output}.bin\""
    run(objcopy)

    with open(f"{output}.bin", 'rb') as f:
        with open(f"{output}.mem", "w") as fout:
            while (word := f.read(4)):
                fout.write(bytes(b for b in reversed(word)).hex() + '\n')
            filled_size = f.tell()
            padding_amt = MEM_SIZE - filled_size
            for _ in range(padding_amt):
                fout.write("00000000\n")


def main():
    global FLAGS
    parser = argparse.ArgumentParser("soft-riscv-compile")
    parser.add_argument("target_dir")
    parser.add_argument("-o", "--output", default='a.out')
    parser.add_argument("-wall", action="store_true")
    parser.add_argument("-O3", action="store_true")
    args = parser.parse_args()

    if (args.O3):
        FLAGS += "-O3 "
    if (args.wall):
        FLAGS += "-Wall -Wextra "

    libpath = sys.path[0]


    #build_libarch(libpath)
    build_target(libpath, args.target_dir, args.output)



if __name__ == "__main__":
    main()