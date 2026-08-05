// Real functional test: write a 4x4 int32 array into a zarr3 array backed by
// OCDBT on a local `file` kvstore, close it, reopen it as a fresh
// TensorStore handle, read it back, and check every value matches. Proves
// actual read/write correctness through the real storage stack (OCDBT
// manifest/btree + riegeli + blake3 + zarr3 codec chain + local file I/O),
// not just that everything links and the process starts.
//
// Storage path: relative to CWD (not a hardcoded absolute path) so this
// works unmodified whether run from a scratch dev tree or an APKBUILD
// check() step, which controls CWD itself.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>

#include <nlohmann/json.hpp>

#include "tensorstore/array.h"
#include "tensorstore/open.h"
#include "tensorstore/open_mode.h"
#include "tensorstore/tensorstore.h"

int main() {
  const std::string storage_path = "./qnx_smoke_test_storage/";

  ::nlohmann::json spec = {
      {"driver", "zarr3"},
      {"kvstore",
       {
           {"driver", "ocdbt"},
           {"base",
            {
                {"driver", "file"},
                {"path", storage_path},
            }},
       }},
      {"metadata",
       {
           {"data_type", "int32"},
           {"shape", {4, 4}},
           {"chunk_grid",
            {{"name", "regular"},
             {"configuration", {{"chunk_shape", {2, 2}}}}}},
       }},
  };

  int32_t data[4][4];
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      data[i][j] = i * 10 + j;
    }
  }

  {
    auto open_result =
        tensorstore::Open(spec, tensorstore::OpenMode::create).result();
    if (!open_result.ok()) {
      std::fprintf(stderr, "Open (create) failed: %s\n",
                    std::string(open_result.status().message()).c_str());
      return 1;
    }
    auto store = *open_result;

    // MakeArray (not MakeArrayView): Write() is async and needs an owned
    // (SharedArray) copy, not a view into stack memory that could go out of
    // scope before the write actually completes.
    auto write_result =
        tensorstore::Write(tensorstore::MakeArray(data), store).result();
    if (!write_result.ok()) {
      std::fprintf(stderr, "Write failed: %s\n",
                    std::string(write_result.status().message()).c_str());
      return 1;
    }
    std::printf("Write succeeded.\n");
  }

  // Fresh TensorStore handle (new Open() call) forces a real reload from
  // storage -- not just reading back the same in-memory handle.
  {
    auto open_result =
        tensorstore::Open(spec, tensorstore::OpenMode::open).result();
    if (!open_result.ok()) {
      std::fprintf(stderr, "Reopen failed: %s\n",
                    std::string(open_result.status().message()).c_str());
      return 1;
    }
    auto store = *open_result;

    auto read_result = tensorstore::Read(store).result();
    if (!read_result.ok()) {
      std::fprintf(stderr, "Read failed: %s\n",
                    std::string(read_result.status().message()).c_str());
      return 1;
    }
    // The store was opened from a plain JSON spec (no compile-time
    // Element/Rank), so read_array is fully type-erased
    // (Array<Shared<void>, -1, ...>). Only cast the element type (leave
    // rank/origin-kind as-is, since Read() results use offset-kind origin,
    // not the zero-kind a SharedArray<T, 2> default would require) and
    // index via an explicit typed span rather than a bare index pack (which
    // doesn't work for dynamic rank).
    auto typed_result = tensorstore::StaticDataTypeCast<int32_t>(*read_result);
    if (!typed_result.ok()) {
      std::fprintf(stderr, "StaticDataTypeCast failed: %s\n",
                    std::string(typed_result.status().message()).c_str());
      return 1;
    }
    auto read_array = *typed_result;

    bool ok = true;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        const tensorstore::Index idx[2] = {i, j};
        int32_t got = read_array(idx);
        int32_t want = data[i][j];
        if (got != want) {
          std::fprintf(stderr, "Mismatch at [%d][%d]: got %d want %d\n", i,
                        j, got, want);
          ok = false;
        }
      }
    }
    std::printf("ALL OK: %s\n", ok ? "true" : "false");
    return ok ? 0 : 1;
  }
}
