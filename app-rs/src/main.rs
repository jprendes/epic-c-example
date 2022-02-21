#![no_std]
#![no_main]

mod htif;

static mut RESULT: u64 = 0x42;
static mut RESULT_REF: &u64 = unsafe { &RESULT };

static HELLO_WORLD: &str = "Hello World!";
static HELLO_WORLD_REF: &&str = &HELLO_WORLD;

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    htif::shutdown(1)
}

#[no_mangle]
pub extern "C" fn main() -> isize {
        htif::print("*HELLO_WORLD_REF = ");
        htif::print(*HELLO_WORLD_REF);
        htif::print("\n");
        htif::print("Address of global HELLO_WORLD is ");
        htif::print((&HELLO_WORLD as *const &str) as u64);
        htif::print(".\n");
        htif::print("Address of global HELLO_WORLD_REF is ");
        htif::print((&HELLO_WORLD_REF as *const &&str) as u64);
        htif::print(".\n");

        unsafe {
            htif::print("*RESULT_REF = ");
            htif::print(*RESULT_REF);
            htif::print("\n");
            htif::print("Address of global RESULT is ");
            htif::print((&RESULT as *const u64) as u64);
            htif::print(".\n");
            htif::print("Address of global RESULT_REF is ");
            htif::print((&RESULT_REF as *const &u64) as u64);
            htif::print(".\n");
            htif::print("Content of global RESULT_REF is ");
            htif::print((RESULT_REF as *const u64) as u64);
            htif::print(".\n");
        }
    0
}