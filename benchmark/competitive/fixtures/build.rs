fn main() {
    let path=std::path::Path::new("../fixtures").canonicalize().unwrap();
    println!("cargo:rustc-link-search=native={}",path.display());
    println!("cargo:rustc-link-lib=static=competitive_sqlite");
    println!("cargo:rustc-link-lib=pthread");
    println!("cargo:rustc-link-lib=m");
    println!("cargo:rerun-if-changed=../fixtures/libcompetitive_sqlite.a");
}
