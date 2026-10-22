# Worktree untuk producer kode

Referensi mode Kode dari `SKILL.md`. Baca sebelum mengirim producer kode pertama.

`isolation: "worktree"` membuat checkout di `<repo>/.claude/worktrees/<name>` dari `origin/<default branch>`, berisi file
tracked saja: tanpa `vendor/`, `node_modules/`, atau `.env`. Konsekuensinya untuk brief:

- Sebut base branch eksplisit. Producer yang harus bekerja di atas branch lain melakukan `git fetch` lalu `git checkout` sendiri,
  dan kamu commit atau push dulu kalau producer butuh perubahanmu.
- Producer memverifikasi kesiapan sebelum menjalankan apa pun: `vendor/` atau `node_modules/` ada, `.env` ada, versi runtime benar
  (`.php-version` atau `.nvmrc`). Kalau repo punya script setup worktree (cari `scripts/worktree-setup.sh` atau hook
  post-checkout), jalankan itu. Kalau tidak ada: `cp -a` dari checkout utama, lalu install dependensi hanya bila lockfile beda.
- `vendor/` selalu disalin, tidak pernah symlink: symlink membuat test diam-diam menjalankan kode checkout utama.
- Bukti test dari worktree hanya sah bila stack trace-nya menunjuk ke path worktree itu.
- Producer paralel tidak berbagi file. Dua producer yang butuh file yang sama berarti satu producer, atau yang kedua menunggu.
- PR bertumpuk dihindari; kalau tak terelakkan, urutan merge masuk ke judul PR dan ke laporanmu.
