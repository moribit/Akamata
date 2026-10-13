package main

/*
#cgo CFLAGS: -I../fixtures
#cgo LDFLAGS: -L../fixtures -lcompetitive_sqlite -lpthread -lm
#include "sqlite.h"
*/
import "C"
import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"strconv"
	"time"
)

func main() {
	if C.competitive_db_init() != 0 {
		log.Fatal("sqlite fixture init failed")
	}
	mux := http.NewServeMux()
	// Acquire on a Go channel before cgo so exhausted DB leases suspend
	// goroutines instead of pinning one C-waiting OS thread per HTTP client.
	dbSlots := make(chan struct{}, 8)
	mux.HandleFunc("GET /plaintext", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		io.WriteString(w, "Hello, World!")
	})
	mux.HandleFunc("GET /json", func(w http.ResponseWriter, r *http.Request) {
		b, err := json.Marshal(struct {
			Message string `json:"message"`
		}{"Hello, World!"})
		if err != nil {
			http.Error(w, "json error", 500)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Write(b)
	})
	mux.HandleFunc("POST /echo", func(w http.ResponseWriter, r *http.Request) {
		b, err := io.ReadAll(http.MaxBytesReader(w, r.Body, 1024*1024))
		if err != nil {
			http.Error(w, "invalid body", 413)
			return
		}
		w.Header().Set("Content-Type", "application/octet-stream")
		w.Write(b)
	})
	mux.HandleFunc("GET /users/{user}/posts/{post}", func(w http.ResponseWriter, r *http.Request) {
		u, e := strconv.ParseUint(r.PathValue("user"), 10, 64)
		p, f := strconv.ParseUint(r.PathValue("post"), 10, 64)
		if e != nil || f != nil {
			http.Error(w, "invalid id", 400)
			return
		}
		b, _ := json.Marshal(struct {
			User uint64 `json:"user"`
			Post uint64 `json:"post"`
		}{u, p})
		w.Header().Set("Content-Type", "application/json")
		w.Write(b)
	})
	mux.HandleFunc("GET /db/1", func(w http.ResponseWriter, r *http.Request) {
		select {
		case dbSlots <- struct{}{}:
		case <-r.Context().Done():
			return
		}
		defer func() { <-dbSlots }()
		var row C.struct_competitive_row
		if C.competitive_db_lookup(&row) < 0 {
			http.Error(w, "db error", 500)
			return
		}
		b, err := json.Marshal(struct {
			ID     int64   `json:"id"`
			Name   string  `json:"name"`
			Weight float64 `json:"weight"`
		}{int64(row.id), C.GoString(&row.name[0]), float64(row.weight)})
		if err != nil {
			http.Error(w, "json error", 500)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Write(b)
	})
	s := http.Server{Addr: "127.0.0.1:8088", Handler: mux, ReadHeaderTimeout: 30 * time.Second, ReadTimeout: 30 * time.Second, WriteTimeout: 30 * time.Second, IdleTimeout: 60 * time.Second, MaxHeaderBytes: 64 * 1024}
	log.Fatal(s.ListenAndServe())
}
