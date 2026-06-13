# Rust Expert Skill

## Core Ownership Rules
- Move semantics by default — only `clone()` when you can't borrow
- Prefer `&T` for read-only, `&mut T` for mutation, owned `T` only when you need it
- Use lifetime annotations only when the compiler forces you — don't add them preemptively
- Avoid `'static` bounds unless you genuinely need the data to outlive all borrows

## Error Handling
```rust
// Library errors: thiserror
#[derive(Debug, thiserror::Error)]
enum MyError {
    #[error("IO failure: {0}")]
    Io(#[from] std::io::Error),
}

// Application errors: anyhow
fn run() -> anyhow::Result<()> {
    let content = std::fs::read_to_string("file")?;
    Ok(())
}
```
- Never `.unwrap()` in production — use `?`, `unwrap_or_else`, or `expect` with a meaningful message
- `.expect("msg")` is acceptable in tests and `fn main()` only
- Use `map_err` to add context: `.map_err(|e| anyhow!("reading config: {e}"))`

## Concurrency
- Prefer channels (`std::sync::mpsc`, `tokio::sync::mpsc`) over shared mutable state
- `Arc<Mutex<T>>` when you truly need shared mutable state across threads
- `Arc<RwLock<T>>` when reads >> writes
- Never hold a mutex lock across an `.await` point
- Use `tokio::spawn` for async tasks, `std::thread::spawn` for CPU-bound work

## Async (Tokio)
```rust
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tokio::join!(task_a(), task_b()); // parallel, not sequential
    Ok(())
}
```
- `tokio::join!` for known set of futures in parallel
- `tokio::spawn` + `JoinSet` for dynamic parallel tasks
- `tokio::select!` for racing multiple futures or adding timeouts

## wgpu / GPU (ThothTerm Context)
- Minimize heap allocations in render hot paths — use `bytemuck::cast_slice` for buffer data
- Prefer `wgpu::Buffer` with `COPY_DST` + `write_buffer` over recreating buffers every frame
- Use `wgpu::ShaderModuleDescriptor` with `include_wgsl!` macro for compile-time shader embedding
- Surface configuration: always handle `wgpu::SurfaceError::Lost` and `Outdated` by reconfiguring
- Use `wgpu::Features::default()` unless you need specific extensions — maximizes compatibility
- `wgpu::Limits::downlevel_webgl2_defaults()` for WASM targets

## WASM (wasm-bindgen)
```toml
[lib]
crate-type = ["cdylib", "rlib"]

[target.'cfg(target_arch = "wasm32")'.dependencies]
wasm-bindgen = "0.2"
web-sys = { version = "0.3", features = ["Window", "Document"] }
```
- Use `#[cfg(target_arch = "wasm32")]` for platform-specific code, not feature flags
- `console_error_panic_hook::set_once()` in WASM init for readable panics
- `wasm_bindgen_futures::spawn_local` for async in WASM (no `tokio` in WASM)

## Performance
- Profile before optimizing — `cargo flamegraph` or `perf`
- Use `#[inline]` on small hot functions; `#[inline(never)]` to isolate in profiles
- `Vec::with_capacity(n)` when size is known ahead of time
- Avoid `Box<dyn Trait>` in hot paths — prefer generics with `impl Trait` or enums
- `SmallVec`, `ArrayVec` for small collections that rarely exceed a fixed size

## Testing
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_thing() {
        assert_eq!(compute(2), 4);
    }
    
    #[tokio::test]
    async fn test_async_thing() {
        assert!(async_compute().await.is_ok());
    }
}
```
- Integration tests go in `tests/` directory, unit tests in `#[cfg(test)]` modules
- Use `insta` crate for snapshot testing of complex outputs
- `proptest` or `quickcheck` for property-based testing of pure functions

## Common Mistakes to Avoid
- Forgetting `mut` on iterator adapters that consume (`.into_iter()` vs `.iter()`)
- Using `String` where `&str` would work — adds unnecessary allocations
- Cloning inside a loop — clone once outside or redesign
- `match` on `Option` when `?`, `map`, `and_then` would be cleaner
- Not implementing `Display` for errors before `Debug`
