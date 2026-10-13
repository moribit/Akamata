use axum::{Router,Json,body::Bytes,extract::{Path,DefaultBodyLimit},http::StatusCode,routing::{get,post},response::{Response,IntoResponse}};
use serde::Serialize;
#[derive(Serialize)] struct Message { message:&'static str }
#[derive(Serialize)] struct Route {user:u64,post:u64}
#[repr(C)] struct Row {id:i64,name:[u8;64],weight:f64}
#[derive(Serialize)] struct Item {id:i64,name:String,weight:f64}
unsafe extern "C" {fn competitive_db_init()->i32;fn competitive_db_lookup(b:*mut Row)->i32;}
async fn plaintext()->impl IntoResponse {([("content-type","text/plain; charset=utf-8")],"Hello, World!")}
async fn json()->Json<Message> {Json(Message{message:"Hello, World!"})}
async fn echo(b:Bytes)->impl IntoResponse {([("content-type","application/octet-stream")],b)}
async fn routing(Path((user,post)):Path<(u64,u64)>)->Json<Route> {Json(Route{user,post})}
async fn db()->Response {
    let mut row=Row{id:0,name:[0;64],weight:0.};
    if unsafe{competitive_db_lookup(&mut row)}<0{return StatusCode::INTERNAL_SERVER_ERROR.into_response()};
    let length=row.name.iter().position(|b|*b==0).unwrap_or(64);
    let name=String::from_utf8(row.name[..length].to_vec()).expect("fixture UTF-8");
    Json(Item{id:row.id,name,weight:row.weight}).into_response()
}
#[tokio::main(worker_threads=8)]
async fn main() {
    assert_eq!(unsafe{competitive_db_init()},0);
    let app=Router::new().route("/plaintext",get(plaintext)).route("/json",get(json)).route("/echo",post(echo)).route("/users/{user}/posts/{post}",get(routing)).route("/db/1",get(db)).layer(DefaultBodyLimit::max(1024*1024));
    let listener=tokio::net::TcpListener::bind("127.0.0.1:8088").await.unwrap();
    axum::serve(listener,app).with_graceful_shutdown(async {tokio::signal::ctrl_c().await.unwrap()}).await.unwrap();
}
