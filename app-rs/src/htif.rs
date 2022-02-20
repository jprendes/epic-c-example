// #![allow(dead_code)]

static mut SYS_DATA: [u64; 8] = [0,0,0,0,0,0,0,0];

const SYS_EXIT: u64 = 93;
const SYS_WRITE: u64 = 64;

fn syscall(args: [u64; 8]) -> u64 {
    unsafe {
        SYS_DATA = args;
        core::ptr::write_volatile(0x0002000 as *mut u64, (&SYS_DATA as *const [u64; 8]) as u64);
        loop {
            let fh = core::ptr::read_volatile(0x0002008 as *const u64);
            if fh != 0 {
                core::ptr::write_volatile(0x0002008 as *mut u64, 0);
                break;
            }
        }
        SYS_DATA[0]
    }
}

pub fn shutdown(code: i32) -> ! {
    syscall([SYS_EXIT, code as u64, 0, 0, 0, 0, 0, 0]);
    loop {
        continue;
    }
}

pub trait Printable {
    fn print(self) -> u64;
}

impl Printable for &str {
    fn print(self) -> u64 {
        syscall([SYS_WRITE, 0, self.as_ptr() as u64, self.len() as u64, 0, 0, 0, 0])
    }
}

impl Printable for &[u8] {
    fn print(self) -> u64 {
        syscall([SYS_WRITE, 0, self.as_ptr() as u64, self.len() as u64, 0, 0, 0, 0])
    }
}

impl<const N: usize> Printable for &[u8; N] {
    fn print(self) -> u64 {
        syscall([SYS_WRITE, 0, self.as_ptr() as u64, self.len() as u64, 0, 0, 0, 0])
    }
}

impl Printable for u64 {
    fn print(self) -> u64 {
        static DIGITS: &[u8] = b"0123456789ABCDEF";
        const N: usize = core::mem::size_of::<u64>() * 2 + 2;
        let mut buffer: [u8; N] = [b'0'; N];
        let mut i = N - 1;

        let mut n = self;

        if n == 0 {
            return print("0x0");
        }

        while n != 0 {
            let t = n & 0x0F;
            buffer[i] = DIGITS[t as usize];
            i -= 1;
            n = n >> 4;
        }

        buffer[i] = b'x';
        i -= 1;
        buffer[i] = b'0';

        print(&buffer[i..])
    }
}

impl Printable for i64 {
    fn print(self) -> u64 {
        if self < 0 {
            print("-");
            print((-self) as u64) + 1
        } else {
            print(self as u64)
        }
    }
}

pub fn print<T: Printable>(s: T) -> u64 {
    Printable::print(s)
}