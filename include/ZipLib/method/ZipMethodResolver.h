#pragma once
#include <cstdint>
#include <memory>
#include "ICompressionMethod.h"

#include "Store.h"
#include "Deflate.h"
#include "Bzip2.h"
#include "Lzma.h"

#define ZIP_METHOD_ADD(method_class)                                                            \
  if (compressionMethod == method_class::GetZipMethodDescriptorStatic().GetCompressionMethod()) \
    return method_class::Create()

struct ZipMethodResolver
{
  static ICompressionMethod::Ptr GetZipMethodInstance(uint16_t compressionMethod)
  {
    #ifndef ZIPLIB_NO_ZLIB
      ZIP_METHOD_ADD(StoreMethod);
      ZIP_METHOD_ADD(DeflateMethod);
    #endif

    #ifndef ZIPLIB_NO_BZIP2
      ZIP_METHOD_ADD(Bzip2Method);
    #endif

    #ifndef ZIPLIB_NO_LZMA
      ZIP_METHOD_ADD(LzmaMethod);
    #endif

    return ICompressionMethod::Ptr();
  }
};

#undef ZIP_METHOD
