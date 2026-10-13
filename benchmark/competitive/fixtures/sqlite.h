#pragma once
int competitive_db_init(void);
struct competitive_row { long long id; char name[64]; double weight; };
int competitive_db_lookup(struct competitive_row *output);
void competitive_db_close(void);
