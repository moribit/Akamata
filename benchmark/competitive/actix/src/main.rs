use actix_web::{web,App,HttpResponse,HttpServer};
use serde::Serialize;
#[derive(Serialize)] struct Message { message: &'static str }
#[derive(Serialize)] struct Route { user:u64, post:u64 }
#[repr(C)] struct Row { id:i64, name:[u8;64], weight:f64 }
#[derive(Serialize)] struct Item { id:i64, name:String, weight:f64 }
unsafe extern "C" { fn competitive_db_init()->i32;fn competitive_db_lookup(b:*mut Row)->i32; }
async fn plaintext()->HttpResponse {HttpResponse::Ok().content_type("text/plain; charset=utf-8").body("Hello, World!")}
async fn json()->HttpResponse {HttpResponse::Ok().json(Message{message:"Hello, World!"})}
async fn echo(b:web::Bytes)->HttpResponse {HttpResponse::Ok().content_type("application/octet-stream").body(b)}
async fn routing(p:web::Path<(u64,u64)>)->HttpResponse {HttpResponse::Ok().json(Route{user:p.0,post:p.1})}
async fn db()->HttpResponse {
    let mut row=Row{id:0,name:[0;64],weight:0.};
    if unsafe{competitive_db_lookup(&mut row)}<0{return HttpResponse::InternalServerError().finish()};
    let length=row.name.iter().position(|b|*b==0).unwrap_or(64);
    let name=String::from_utf8(row.name[..length].to_vec()).expect("fixture UTF-8");
    HttpResponse::Ok().json(Item{id:row.id,name,weight:row.weight})
}
#[actix_web::main]
async fn main()->std::io::Result<()> {
    assert_eq!(unsafe{competitive_db_init()},0);
    HttpServer::new(||App::new().app_data(web::PayloadConfig::new(1024*1024))
      .route("/plaintext",web::get().to(plaintext)).route("/json",web::get().to(json))
      .route("/echo",web::post().to(echo)).route("/users/{user}/posts/{post}",web::get().to(routing))
      .route("/db/1",web::get().to(db)))
      .workers(8).keep_alive(std::time::Duration::from_secs(60)).bind("127.0.0.1:8088")?.run().await
}
