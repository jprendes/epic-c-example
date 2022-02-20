#![no_std]
#![no_main]

mod htif;

static mut RESULT: u64 = 0x42;

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    htif::shutdown(1)
}

#[no_mangle]
#[inline(never)]
pub extern "C" fn some_function() -> u64 {
    unsafe {
        (&RESULT as *const u64) as u64
    }
}

#[no_mangle]
pub extern "C" fn main() -> isize {
    let res = htif::print("Hello World!\n");
    unsafe {
        htif::print("The `print` syscall result was ");
        htif::print(RESULT);
        htif::print(".\n");
        core::ptr::write_volatile(&mut RESULT as *mut u64, res);
        htif::print("Address of some mutable global is ");
        htif::print(some_function());
        htif::print(".\n");
        htif::print("Address of some constant global is ");
        htif::print(("Hello world!".as_ptr()) as u64);
        htif::print(".\n");
        htif::print("The `print` syscall result was ");
        htif::print(RESULT);
        htif::print(".\n");
    }
    0
}