/* Benchmark-only glue, not a new Akamata database API. All non-Akamata fixtures
 * link this exact SQLite amalgamation and use eight independently owned handles.
 * No cached statement; output is copied before release. No arbitrary SQL/input. */
#include "sqlite.h"
#include "sqlite3.h"
#include <pthread.h>
#include <string.h>
static sqlite3 *dbs[8];
static int used[8];
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t returned = PTHREAD_COND_INITIALIZER;
void competitive_db_close(void) {
    for (int i=0;i<8;i++) { if(dbs[i]) sqlite3_close(dbs[i]); dbs[i]=0; }
}
int competitive_db_init(void) {
    for(int i=0;i<8;i++) {
        if(sqlite3_open_v2(":memory:", &dbs[i], SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE|SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_URI, 0)!=SQLITE_OK) goto fail;
        if(sqlite3_exec(dbs[i], "PRAGMA journal_mode=MEMORY; PRAGMA synchronous=OFF; PRAGMA temp_store=MEMORY; CREATE TABLE items(id INTEGER PRIMARY KEY,name TEXT NOT NULL,weight REAL); INSERT INTO items VALUES(1,'alpha',1.5),(2,'beta',2.5),(3,'gamma',3.5);",0,0,0)!=SQLITE_OK) goto fail;
    }
    return 0;
fail: competitive_db_close(); return -1;
}
int competitive_db_lookup(struct competitive_row *output) {
    int slot=-1, n=-1;
    pthread_mutex_lock(&lock);
    while(slot<0) {
        for(int i=0;i<8;i++) if(!used[i]) { used[i]=1;slot=i;break; }
        if(slot<0) pthread_cond_wait(&returned,&lock);
    }
    pthread_mutex_unlock(&lock);
    sqlite3_stmt *stmt=0;
    if(sqlite3_prepare_v2(dbs[slot],"SELECT id, name, weight FROM items WHERE id = ?",-1,&stmt,0)==SQLITE_OK &&
       sqlite3_bind_int64(stmt,1,1)==SQLITE_OK && sqlite3_step(stmt)==SQLITE_ROW) {
        const unsigned char *name=sqlite3_column_text(stmt,1);
        const int length=sqlite3_column_bytes(stmt,1);
        if(name && length>=0 && length<(int)sizeof(output->name)) {
            output->id=sqlite3_column_int64(stmt,0);
            memcpy(output->name,name,(size_t)length);output->name[length]=0;
            output->weight=sqlite3_column_double(stmt,2);n=0;
        }
    }
    if(stmt) sqlite3_finalize(stmt);
    pthread_mutex_lock(&lock);used[slot]=0;pthread_cond_signal(&returned);pthread_mutex_unlock(&lock);
    return n;
}
