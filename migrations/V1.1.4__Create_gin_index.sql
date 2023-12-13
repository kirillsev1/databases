create extension if not exists pg_trgm;
create index ngram_text_search on expedition using gin(name gin_trgm_ops);
create extension if not exists fuzzystrmatch;
