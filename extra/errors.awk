# Usage:
# $ LUA_FUZZER_VERBOSE=1 luaL_loadbuffer_proto_test 2>&1 | tee log.txt
# $ awk errors.awk < log.txt

BEGIN { matched = 0
        err_pat["attempt to index"] = 0
        err_pat["attempt to call"] = 0
        err_pat["no loop to break"] = 0
        err_pat["attempt to perform arithmetic on"] = 0
        err_pat["attempt to compare"] = 0
        err_pat["attempt to concatenate"] = 0
        err_pat["initial value must be"] = 0
        err_pat["unexpected symbol near"] = 0
        err_pat["ambiguous syntax"] = 0
        err_pat["bad argument"] = 0
        err_pat["'end' expected"] = 0
        err_pat["'for' limit must be a"] = 0
        err_pat["'for' step must be a"] = 0
        err_pat["attempt to get length of"] = 0
        err_pat["table index is"] = 0
        err_pat["cannot use '...' outside a vararg function near '...'"] = 0
        err_pat["'<name>' expected near"] = 0
      }

!/^luaL_loadbuffer|^lua_pcall/ { next }

      { err_matched = 0
        for (p in err_pat) {
          if ($0 ~ p) { ++err_pat[p]; ++matched; err_matched = 1 }
        }
        if (err_matched == 0) { printf("[UNMATCHED] %s\n", $0) }
      }

END   { printf("\n%7s    %s\n\n", "NUM", "ERROR MESSAGE")
        for (p in err_pat) { printf("%7d    %s\n", err_pat[p], p) }
        printf("\n%7d    TOTAL\n", matched)
      }
