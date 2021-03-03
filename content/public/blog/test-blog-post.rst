
===================================
Using LLVM Sanitizers with Nim-Lang
===================================

Recently I've been using `Nim`_ as my go-to language for writing software in. One of the advantages that comes with Nim is the strong and easy to implmenent bridging behavior to C-family libraries. I recently put up a PR for Nim, which has since got merged, that enables some out of the box functionality for working with some of the Sanitizers that come as part of the LLVM toolchain.

.. _Nim: https://nim-lang.org

The `Address Sanitizer (ASAN)`_ is a tool that enables runtime checking of memory behavior and usage. Likewise, the `Thread Sanitizer (TSAN)`_ is a tool to check for data races and other thread-safety issues. These are useful tools when working with code in any C-family language. While Nim isn't part of the C-family, the Nim compiler does convert Nim code into C before final compilation to assembly. Because of this, we can take advantage of the tooling provided to help debug our Nim code. To do this, a few additional flags need to be passed to the Nim compiler:

.. _`Address Sanitizer (ASAN)`: http://clang.llvm.org/docs/AddressSanitizer.html
.. _`Thread Sanitizer (TSAN)`: http://clang.llvm.org/docs/ThreadSanitizer.html


.. code-block::

    # set this if you have Xcode.app installed
    clang_libraries_path="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/#.#.#/lib/darwin"

    # set this if you have the Xcode Command Line Tools installed
    clang_libraries_path="/Library/Developer/CommandLineTools/usr/lib/clang/#.#.#/lib/darwin"

    # this is to say use this search path for libraries to link against
    --passL:"-L$clang_libraries_path"
    # this is to say include the @rpath in the resulting binary to specify where to look for the clang libraries
    --passL:"-rpath $clang_libraries_path"

    # link against the ASAN dynamic library to take advantage of runtime checks
    --passL:"-lclang_rt.asan_osx_dynamic"
    # pass the flag to the C compiler to tell it to utilize the ASAN instrumentation
    --passC:"-fsanitize=address"

    # link against the TSAN dynamic library to take advantage of runtime checks
    --passL:"-lclang_rt.tsan_osx_dynamic"
    # pass the flag to the C compiler to tell it to utilize the TSAN instrumentation
    --passC:"-fsanitize=thread"

