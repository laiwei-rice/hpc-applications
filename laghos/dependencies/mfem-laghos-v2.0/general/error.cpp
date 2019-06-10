// Copyright (c) 2010, Lawrence Livermore National Security, LLC. Produced at
// the Lawrence Livermore National Laboratory. LLNL-CODE-443211. All Rights
// reserved. See file COPYRIGHT for details.
//
// This file is part of the MFEM library. For more information and source code
// availability see http://mfem.org.
//
// MFEM is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License (as published by the Free
// Software Foundation) version 2.1 dated February 1999.

#include "error.hpp"
#include "globals.hpp"
#include "array.hpp"
#include <cstdlib>
#include <iostream>

#ifdef MFEM_USE_LIBUNWIND
#define UNW_LOCAL_ONLY
#define UNW_NAME_LEN 512
#include <libunwind.h>
#include <cxxabi.h>
#if defined(__APPLE__) || defined(__linux__)
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <dlfcn.h>
#endif
#endif // MFEM_USE_LIBUNWIND

#ifdef MFEM_USE_MPI
#include <mpi.h>
#endif

namespace mfem
{

#ifdef MFEM_USE_EXCEPTIONS
const char* ErrorException::what() const throw()
{
   return msg.c_str();
}

static ErrorAction mfem_error_action = MFEM_ERROR_THROW;
#else
static ErrorAction mfem_error_action = MFEM_ERROR_ABORT;
#endif

void set_error_action(ErrorAction action)
{
   // Check if 'action' is valid.
   switch (action)
   {
      case MFEM_ERROR_ABORT: break;
      case MFEM_ERROR_THROW:
#ifdef MFEM_USE_EXCEPTIONS
         break;
#else
         mfem_error("set_error_action: MFEM_ERROR_THROW requires the build "
                    "option MFEM_USE_EXCEPTIONS=YES");
         return;
#endif
      default:
         mfem::err << "\n\nset_error_action: invalid action: " << action
                   << '\n';
         mfem_error();
         return;
   }
   mfem_error_action = action;
}

ErrorAction get_error_action()
{
   return mfem_error_action;
}

void mfem_backtrace(int mode, int depth)
{
#ifdef MFEM_USE_LIBUNWIND
   char name[UNW_NAME_LEN];
   unw_cursor_t cursor;
   unw_context_t uc;
   unw_word_t ip, offp;

   int err = unw_getcontext(&uc);
   err = err ? err : unw_init_local(&cursor, &uc);

   Array<unw_word_t> addrs;
   while (unw_step(&cursor) > 0 && addrs.Size() != depth)
   {
      err = err ? err : unw_get_proc_name(&cursor, name, UNW_NAME_LEN, &offp);
      err = err ? err : unw_get_reg(&cursor, UNW_REG_IP, &ip);
      if (err) { break; }
      char *name_p = name;
      int demangle_status;

      // __cxa_demangle is not standard, but works with GCC, Intel, PGI, Clang
      char *name_demangle =
         abi::__cxa_demangle(name, NULL, NULL, &demangle_status);
      if (demangle_status == 0) // use mangled name if something goes wrong
      {
         name_p = name_demangle;
      }

      mfem::err << addrs.Size() << ") [0x" << std::hex << ip - 1 << std::dec
                << "]: " << name_p << std::endl;
      addrs.Append(ip - 1);

      if (demangle_status == 0)
      {
         free(name_demangle);
      }
   }
#if defined(__APPLE__) || defined(__linux__)
   if (addrs.Size() > 0 && (mode & 1))
   {
      mfem::err << "\nLookup backtrace source lines:";
      const char *fname = NULL;
      for (int i = 0; i < addrs.Size(); i++)
      {
         Dl_info info;
         err = !dladdr((void*)addrs[i], &info);
         if (err)
         {
            fname = "<exe>";
         }
         else if (fname != info.dli_fname)
         {
            fname = info.dli_fname;
            mfem::err << '\n';
#ifdef __linux__
            mfem::err << "addr2line -C -e " << fname;
#else
            mfem::err << "atos -o " << fname << " -l "
                      << (err ? 0 : info.dli_fbase);
#endif
         }
         mfem::err << " 0x" << std::hex << addrs[i] << std::dec;
      }
      mfem::err << '\n';
   }
#endif
#endif // MFEM_USE_LIBUNWIND
}

void mfem_error(const char *msg)
{
   if (msg)
   {
      // NOTE: By default, each call of the "operator <<" method of the
      // mfem::err object results in flushing the I/O stream, which can be a
      // very bad thing if all your processors try to do it at the same time.
      mfem::err << "\n\n" << msg << "\n";
   }

#ifdef MFEM_USE_LIBUNWIND
   mfem::err << "Backtrace:" << std::endl;
   mfem_backtrace(1, -1);
   mfem::err << std::endl;
#endif

#ifdef MFEM_USE_EXCEPTIONS
   if (mfem_error_action == MFEM_ERROR_THROW)
   {
      throw ErrorException(msg);
   }
#endif

#ifdef MFEM_USE_MPI
   int init_flag, fin_flag;
   MPI_Initialized(&init_flag);
   MPI_Finalized(&fin_flag);
   if (init_flag && !fin_flag) { MPI_Abort(GetGlobalMPI_Comm(), 1); }
#endif
   std::abort(); // force crash by calling abort
}

void mfem_warning(const char *msg)
{
   if (msg)
   {
      mfem::out << "\n\n" << msg << std::endl;
   }
}

}
