# Salat Banjarmasin — Garmin Forerunner 165

Aplikasi Connect IQ sederhana berbahasa Indonesia untuk lima waktu salat di
Banjarmasin. Jadwal dihitung setiap hari di jam, tanpa GPS, internet, atau ponsel.

## Fitur dan penggunaan

- Jadwal Subuh, Zuhur, Asar, Magrib, Isya dan hitung mundur salat berikutnya.
- Sesudah Isya, hitung mundur otomatis menuju Subuh esok hari.
- Waktu selalu **WITA (UTC+8)** untuk koordinat pusat Banjarmasin
  **-3.3194, 114.5908**, meskipun zona waktu jam berubah. Bukan mode lokasi otomatis.
- Buka aplikasi sekali setelah pemasangan agar pengingat terdaftar ketika keluar.
- Tekan START atau tahan UP/MENU untuk menu: aktif/mati pengingat, koreksi
  seluruh jadwal ±1 menit (batas -15 hingga +15), dan tes getaran.
- Status pengingat dan koreksi terlihat di bagian bawah layar. Pengingat aktif
  secara bawaan; koreksi awal +2 menit.
- Saat layar utama terbuka, pengingat menampilkan nama salat selama satu menit
  dan memberikan dua getaran. Pemeriksaan waktu dan getaran tetap berjalan
  saat menu terbuka; nama salat terlihat setelah kembali ke layar utama.
- Setelah keluar dari aplikasi, layanan background meminta Garmin menampilkan
  dialog “Waktu [salat]”. Pilih buka untuk melihat jadwal. Jadwal berikutnya
  didaftarkan kembali secara otomatis, termasuk jika dialog ditutup.
- Getaran dialog background mengikuti perilaku sistem Garmin; aplikasi tidak
  menjanjikan alarm suara, adzan, atau getaran background yang dapat dipaksa.
  Mode Jangan Ganggu dan kondisi perangkat perlu diuji di jam sebenarnya.
- Pengingat yang terlambat kurang dari 5 menit masih ditampilkan; pengingat
  yang lebih lama dilewati. Setiap waktu hanya diingatkan sekali.
- Jika mengubah pengaturan dari ponsel, buka lalu keluar dari aplikasi untuk
  memastikan pengingat dijadwalkan ulang. Atur tanggal/jam perangkat dengan benar.

## Metode jadwal

Perhitungan posisi matahari (deklinasi dan equation of time), Subuh -20°,
Isya -18°, Asar faktor bayangan 1, dan Magrib ketinggian matahari -0,833°.
Dibulatkan ke menit berikutnya, lalu ditambah koreksi pengguna (+2 menit awal).
Posisi matahari dihitung pada tengah hari WITA, tanpa koreksi elevasi medan.

**Ini estimasi astronomi, bukan jadwal resmi Kemenag atau masjid setempat.**
Bandingkan jadwal sebelum penggunaan sehari-hari. Koreksi yang tersedia berlaku
untuk semua waktu sekaligus; tidak menggantikan perbedaan metode per salat.
Lokasi tetap Banjarmasin: jangan gunakan jadwal ini untuk kota lain.

Referensi algoritme: https://praytimes.org/wiki/Prayer_Times_Calculation
Referensi layanan pengingat: https://developer.garmin.com/connect-iq/api-docs/Toybox/Background.html

## Build dan simulator

Prasyarat: Garmin Connect IQ SDK, profil perangkat `fr165`, Java, dan developer
key. Di VS Code, gunakan ekstensi Monkey C untuk memilih SDK dan developer key.
Jangan masukkan private key ke repositori.

```sh
monkeyc -f monkey.jungle -d fr165 -o bin/PrayerReminder.prg -y /path/to/developer_key.der -w
connectiq
monkeydo bin/PrayerReminder.prg fr165
```

Build yang tersedia di `bin/PrayerReminder.prg` ditandatangani dengan key lokal
sementara untuk pengujian. Gunakan developer key sendiri untuk build berikutnya
atau distribusi. Target saat ini hanya **Forerunner 165 non-Music (`fr165`)**.

Pengujian otomatis pada simulator:

```sh
monkeyc -f monkey.jungle -d fr165 -o bin/PrayerReminder-tests.prg -y /path/to/developer_key.der -w -t
monkeydo bin/PrayerReminder-tests.prg fr165 -t
```

Tes mencakup tengah malam WITA, pergantian ke Subuh esok hari, urutan jadwal
selama 367 hari termasuk tahun kabisat, koreksi, batas keterlambatan 5 menit,
dan pencegahan pengingat ganda. Tes ini tidak mengesahkan akurasi jadwal resmi.

## Pasang untuk pengujian di jam

1. Hubungkan Forerunner 165 lewat kabel USB data.
2. Akses penyimpanan jam (di macOS mungkin memerlukan aplikasi transfer MTP).
3. Salin `bin/PrayerReminder.prg` ke folder `GARMIN/APPS`.
4. Putuskan perangkat dengan aman, lalu buka **Salat Banjarmasin** dari daftar aplikasi.
5. Coba **Tes getaran**, periksa jadwal, lalu keluar agar background aktif.

Pengujian perangkat yang masih diperlukan: pengingat saat aplikasi ditutup,
menutup/menerima dialog lalu pengingat berikutnya, mode Jangan Ganggu, setelah
restart jam, serta ukuran teks dan getaran pada perangkat fisik. Buka ulang
aplikasi setelah restart/perubahan jam jika diperlukan untuk mendaftarkan ulang.
