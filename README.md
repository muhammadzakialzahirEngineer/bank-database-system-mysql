# 🏦 Sistem Basis Data Perbankan (Bank Database System)

Database MySQL/MariaDB untuk simulasi sistem perbankan sederhana. Proyek ini mengelola data nasabah, rekening, dan transaksi transfer antar rekening, dilengkapi dengan **stored procedure**, **function**, dan **trigger** untuk validasi saldo serta pencatatan log transaksi secara otomatis.

## 📋 Deskripsi

Database ini dirancang untuk mendemonstrasikan implementasi objek basis data lanjutan (advanced database objects) dalam studi kasus perbankan, meliputi:

- Manajemen data nasabah dan rekening
- Proses transfer saldo antar rekening dengan mekanisme transaksi (commit/rollback)
- Validasi otomatis agar saldo tidak pernah bernilai negatif
- Pencatatan log aktivitas transaksi secara otomatis

## ERD

<p align="center">
<img width="644" height="197" alt="image" src="https://github.com/user-attachments/assets/7ef76b7e-ff7b-4df7-b819-f09e172b97c5" />
</p>

## Relasi tabel

<p align="center">
<img width="625" height="329" alt="image" src="https://github.com/user-attachments/assets/71323a8d-a70c-4963-b098-fb0bace75bcb" />
</p>

## 🗂️ Struktur Tabel

| Tabel | Deskripsi |
|---|---|
| `nasabah` | Menyimpan data identitas nasabah (nama, alamat, no. HP) |
| `rekening` | Menyimpan data rekening milik nasabah beserta saldo dan jenis rekening |
| `transaksi` | Mencatat setiap transaksi transfer antar rekening |
| `log_transaksi` | Log otomatis dari setiap transaksi yang terjadi |
| `user_bank` | Menyimpan akun pengguna/admin sistem (username & password) |

## ⚙️ Stored Procedure

| Procedure | Fungsi |
|---|---|
| `tambah_nasabah(p_id, p_nama, p_alamat, p_nohp)` | Menambahkan data nasabah baru |
| `transfer_saldo(p_sumber, p_tujuan, p_jumlah)` | Melakukan transfer saldo antar rekening, otomatis rollback jika saldo tidak mencukupi |

## 🧮 Function

| Function | Fungsi |
|---|---|
| `cek_saldo(p_no_rekening)` | Mengembalikan saldo terkini dari sebuah rekening |
| `total_transfer(p_rekening)` | Menghitung total dana yang telah ditransfer keluar dari sebuah rekening |

## 🔔 Trigger

| Trigger | Tabel | Event | Fungsi |
|---|---|---|---|
| `before_update_saldo` | `rekening` | BEFORE UPDATE | Mencegah saldo rekening menjadi negatif |
| `after_insert_transaksi` | `transaksi` | AFTER INSERT | Otomatis mencatat log setiap transaksi baru ke tabel `log_transaksi` |

## 🚀 Cara Instalasi / Import

1. Buat database baru di MySQL/MariaDB (misalnya melalui phpMyAdmin atau CLI):
   ```sql
   CREATE DATABASE bank_database;
   ```
2. Pilih (gunakan) database yang baru dibuat.
3. Import file `.sql` ini melalui salah satu cara berikut:
   - **phpMyAdmin**: pilih database → tab *Import* → pilih file `.sql` → klik *Go*
   - **Command line**:
     ```bash
     mysql -u root -p bank_database < nama_file.sql
     ```
4. Database beserta seluruh tabel, data awal, procedure, function, dan trigger akan otomatis terbentuk.

> ℹ️ Nama file `.sql` bebas diganti sesuai keinginan — tidak memengaruhi isi maupun fungsi database.

## 🧪 Contoh Penggunaan

**Memanggil procedure transfer saldo:**
```sql
CALL transfer_saldo('REK-001', 'REK-002', 500000.00);
```

**Mengecek saldo rekening:**
```sql
SELECT cek_saldo('REK-001');
```

**Menghitung total transfer keluar dari suatu rekening:**
```sql
SELECT total_transfer('REK-001');
```

## 🛠️ Requirements

- MySQL 5.7+ atau MariaDB 10.4+
- phpMyAdmin (opsional, untuk import via GUI)

## 📄 Lisensi

Proyek ini dibuat untuk tujuan pembelajaran/tugas mata kuliah Sistem Basis Data (SBD). Bebas digunakan dan dimodifikasi.
