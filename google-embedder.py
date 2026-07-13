#!/usr/bin/env python3
"""
Standalone semantic embedder + search for ~/brain using Google's NATIVE
embedding endpoint (generativelanguage.googleapis.com ... :embedContent).

This is NOT gbrain's pipeline (gbrain only speaks ZeroEntropy/OpenAI/Voyage).
It is a self-contained indexer so the user's Google AI Studio key can power
real semantic search over their markdown notes.

Secrets: reads GOOGLE_AI_STUDIO_API_KEY from env (sourced from git-ignored
~/.secrets.env). Never printed.

Usage:
  google-embedder.py index      # (re)build the vector store from ~/brain
  google-embedder.py search "query string" [--top N]
  google-embedder.py stats
"""
import os, sys, json, math, glob, argparse
from pathlib import Path

BRAIN = Path(os.path.expanduser("~/brain"))
STORE = Path(os.path.expanduser("~/.gbrain/google-embed-store.jsonl"))
MODEL = "gemini-embedding-001"
EMBED_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:embedContent"
CHUNK_CHARS = 1000
OVERLAP = 150

def api_key():
    k = os.environ.get("GOOGLE_AI_STUDIO_API_KEY")
    if not k:
        sys.exit("ERROR: GOOGLE_AI_STUDIO_API_KEY not set (source ~/.secrets.env)")
    return k

import time

def embed_text(text: str, tries: int = 6):
    import urllib.request
    body = json.dumps({"content": {"parts": [{"text": text}]}}).encode()
    url = f"{EMBED_URL}?key={api_key()}"
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    delay = 4.0
    for attempt in range(tries):
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                data = json.load(r)
            return data["embedding"]["values"]
        except urllib.error.HTTPError as e:
            if e.code == 429 and attempt < tries - 1:
                time.sleep(delay)
                delay *= 1.8  # back off
                continue
            sys.exit(f"EMBED HTTP {e.code}: {e.read().decode()[:300]}")
        except Exception as e:
            sys.exit(f"EMBED ERROR: {e}")

def chunk_text(text: str):
    text = text.strip()
    if not text:
        return []
    chunks = []
    start = 0
    while start < len(text):
        chunks.append(text[start:start + CHUNK_CHARS])
        if start + CHUNK_CHARS >= len(text):
            break
        start += CHUNK_CHARS - OVERLAP
    return chunks

def collect_md():
    files = []
    for p in BRAIN.rglob("*.md"):
        if ".git" in p.parts:
            continue
        files.append(p)
    return sorted(files)

def cosine(a, b):
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(y * y for y in b))
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)

def _load_existing():
    if not STORE.exists():
        return {}, []
    rows = [json.loads(l) for l in STORE.read_text(encoding="utf-8").splitlines() if l.strip()]
    done = {(r["file"], r["chunk"]) for r in rows}
    return done, rows

def cmd_index():
    files = collect_md()
    done, rows = _load_existing()
    print(f"Indexing {len(files)} markdown file(s) from {BRAIN} (resume: {len(done)} already done)")
    STORE.parent.mkdir(parents=True, exist_ok=True)
    added = 0
    with open(STORE, "a", encoding="utf-8") as f:
        for fp in files:
            try:
                text = fp.read_text(encoding="utf-8", errors="ignore")
            except Exception as e:
                print(f"  skip {fp}: {e}")
                continue
            rel = str(fp.relative_to(BRAIN))
            for i, chunk in enumerate(chunk_text(text)):
                if (rel, i) in done:
                    continue
                vec = embed_text(chunk)
                rec = {"file": rel, "chunk": i, "text": chunk, "vec": vec}
                f.write(json.dumps(rec, ensure_ascii=False) + "\n")
                rows.append(rec); added += 1
                done.add((rel, i))
                print(f"  {rel} [{i}] -> {len(vec)}d  (total {len(rows)})", end="\r")
    print(f"\nIndexed {added} new chunks (total {len(rows)}) -> {STORE}")

def cmd_search(query, top=5):
    if not STORE.exists():
        sys.exit("No store found. Run: google-embedder.py index")
    qv = embed_text(query)
    rows = [json.loads(l) for l in STORE.read_text(encoding="utf-8").splitlines() if l.strip()]
    scored = sorted(rows, key=lambda r: cosine(qv, r["vec"]), reverse=True)[:top]
    print(f"\nTop {top} matches for: {query}\n" + "=" * 60)
    for r in scored:
        print(f"\n[{r['file']} #{r['chunk']}] sim={cosine(qv, r['vec']):.3f}")
        snippet = r["text"].replace("\n", " ")
        print(snippet[:400])

def cmd_stats():
    if not STORE.exists():
        print("No store. Run index first.")
        return
    rows = [json.loads(l) for l in STORE.read_text(encoding="utf-8").splitlines() if l.strip()]
    files = {r["file"] for r in rows}
    print(f"Store: {STORE}")
    print(f"Chunks: {len(rows)}  Files: {len(files)}  Dims: {len(rows[0]['vec']) if rows else 0}")

def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("index")
    sp = sub.add_parser("search")
    sp.add_argument("query")
    sp.add_argument("--top", type=int, default=5)
    sub.add_parser("stats")
    args = ap.parse_args()
    if args.cmd == "index":
        cmd_index()
    elif args.cmd == "stats":
        cmd_stats()
    elif args.cmd == "search":
        cmd_search(args.query, args.top)

if __name__ == "__main__":
    main()
