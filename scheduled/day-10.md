---
title: "Rust Panic Traces: From 2% Savings to 80%"
published: false
description: "Rust panic backtraces include 20-30 runtime frames that add nothing to debugging. ContextZip strips them down to the 2-3 frames that actually matter."
tags:
  - ai
  - rust
  - productivity
  - opensource
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
---

A simple Rust panic — `unwrap()` on a `None` — produces a backtrace with 20-30 frames. Most are `std::rt::lang_start`, `std::panicking::*`, and `core::result::*` internals. Your bug is in 2-3 frames.

With tokio? It gets wild. An async runtime panic can produce 60+ frames because every `.await` adds scheduler frames.

## Before: Tokio Panic Backtrace

```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: ConnectionRefused', src/db.rs:42:10
stack backtrace:
   0: std::panicking::begin_panic_handler
   1: core::panicking::panic_fmt
   2: core::result::unwrap_failed
   3: core::result::Result<T,E>::unwrap
   4: myapp::db::connect
             at ./src/db.rs:42:10
   5: myapp::main::{{closure}}
             at ./src/main.rs:15:5
   6: <core::future::from_generator::GenFuture<T> as core::future::Future>::poll
   7: tokio::runtime::task::core::Core<T,S>::poll
   8: tokio::runtime::task::harness::Harness<T,S>::poll
   9: tokio::runtime::scheduler::multi_thread::worker::Context::run_task
  10: tokio::runtime::scheduler::multi_thread::worker::Context::run
  11: tokio::runtime::context::runtime::enter_runtime
  12: tokio::runtime::scheduler::multi_thread::worker::launch
  13: <tokio::runtime::blocking::task::BlockingTask<T> as core::future::Future>::poll
  14: std::thread::local::LocalKey<T>::with
  15: std::rt::lang_start_internal
  16: std::rt::lang_start
  17: main
```

18 frames. Your AI needs frames 4 and 5.

## After: Through ContextZip

```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: ConnectionRefused', src/db.rs:42:10
   4: myapp::db::connect
             at ./src/db.rs:42:10
   5: myapp::main::{{closure}}
             at ./src/main.rs:15:5
💾 contextzip: 1,456 → 287 chars (80% saved)
```

Panic message preserved. Your application frames preserved. Runtime and scheduler internals stripped. 80% reduction.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
