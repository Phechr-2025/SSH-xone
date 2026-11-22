# รายงานวิเคราะห์และสิ่งที่ปรับ

## แหล่งสคริปต์ที่ตรวจ

- `NevermoreSSH/hop` เป็นชุด Bash แบบติดตั้งบริการหลายตัว โดยแยกงานเป็นโฟลเดอร์ เช่น `ssh/`, `xray/`, `ipsec/`, `wireguard/`, `update/` และ `hapus/` เมนูเดิมอยู่ใน `update/menu.sh` และ updater เดิมลบ/ดาวน์โหลดไฟล์เมนูทีละตัวจาก URL ที่ฝังเจ้าของเดิมไว้
- `NevermoreSSH/VVV` มี `badvpn/` พร้อม unit สำหรับ BadVPN UDP gateway ที่พอร์ต 7100/7200/7300 และหน้าสถานะที่รู้จักชื่อ unit `udp-custom` แต่ตัวติดตั้ง `update/updatemenu.sh` คอมเมนต์คำสั่งติดตั้ง UDP Custom ไว้ และชี้ไปยัง `NevermoreSSH/Vergil/Tunnel/udp.sh`
- โค้ดติดตั้ง UDP ที่ใช้งานจริงอยู่ใน `Vergil/Tunnel/udp.sh` สคริปต์นั้นติดตั้ง `udp-custom` และ `config.json` ลง `/root/udp`, สร้าง `udp-custom.service` และเปิดบริการเมื่อบูต ค่า config ต้นทางกำหนด `listen` เป็น `:36712` แม้ README ของ VVV จะอธิบายช่วง UDP Custom เป็น 1–65535

## สิ่งที่ทำตามข้อกำหนด

1. เพิ่มบริการ UDP Custom โดยรวมไบนารี Linux amd64 และ `config.json` ที่ใช้ในต้นทาง พร้อมสคริปต์ติดตั้งและ unit `udp-custom.service`
2. สร้าง UDP menu สำหรับติดตั้ง/ซ่อม, start, stop, restart, ดูสถานะ และถอน UDP โดยสำรอง `config.json` ก่อนซ่อม และให้เลือกเก็บหรือลบ config ตอนถอน
3. จัดเมนูหลักใหม่ครบ 25 รายการตามลำดับที่ขอ เพิ่ม UDP เป็นข้อ 1 และเพิ่ม Version ใน server information
4. เปลี่ยนบรรทัดเครดิตบนเมนูเป็นชื่อจาก `PROJECT_BRAND` ซึ่งตั้งค่าเริ่มต้นจาก `PROJECT_GITHUB_OWNER`
5. ข้อ 17 ใช้ชื่อ `UPDATE SSH / MENU (Update)` เพื่อรวมคำขอ `UPDATE SSH` และ `UPDATE MENU` ที่ระบุเลข 17 ซ้ำกัน ตัวอัปเดตดาวน์โหลด archive ทั้ง repository จาก owner/repository/branch ใน config, ตรวจว่ามีไฟล์หลัก และเก็บชุดเดิมไว้เป็น `/opt/<PROJECT_NAME>.previous` พร้อมผูกคำสั่ง `updatemenu`
6. ใช้ `config.env` เดิมของ repository เป็นจุดแก้ owner, repository, branch, ชื่อแสดงผล, domain และ Cloudflare email/key พร้อมเปลี่ยน URL ของไฟล์ `hop` ภายในให้สร้างจากค่ากลาง
7. ทำตัวถอนติดตั้งแบบยืนยันคำว่า `REMOVE`, สำรองข้อมูลก่อน, หยุดและถอด unit ที่รู้จัก, เอาคำสั่งเมนูออก และคงบัญชี Linux/แพ็กเกจ/config ไว้ตามค่าเริ่มต้น ใช้ `--purge-data` เพื่อลบข้อมูล config หลังสำรอง
8. เพิ่มตัวนับ UDP แยกจาก SSH ในแถวสรุป (แสดง 0 เพราะ UDP Custom เป็นบริการร่วม ไม่ได้มีรายการบัญชีผู้ใช้)
9. แสดง short commit SHA จาก GitHub API ใน Version บนเมนู
10. เพิ่ม `install.sh` สำหรับ Debian 9/10/11 และ Ubuntu 18.04/20.04 และตัวอย่างคำสั่งติดตั้งที่วางครั้งเดียวใน README
11. เปลี่ยน `backup/rclone.conf` เป็น template ว่าง หลังพบ OAuth access/refresh token ฝังอยู่ในไฟล์เดิม

## ข้อจำกัดที่ยังมี

- ไฟล์ `udp-custom` เป็นไบนารี amd64 ที่รวมมาให้ จึงไม่รองรับ VPS ARM และไม่ได้มีซอร์สไบนารีใน repository ชุดส่งมอบ
- `VVV` ไม่มีซอร์สเมนู UDP Custom ที่ครบถ้วนให้ย้ายโดยตรง การทำงานจึงอ้างอิง config, systemd service และตัวติดตั้งจาก `Vergil/Tunnel/udp.sh` ซึ่ง VVV ชี้ไปหา
- Updater อัปเดตต้นไม้สคริปต์ใน `/opt/<PROJECT_NAME>` และจุดเชื่อมเมนู/คำสั่งกลาง แต่ไม่ได้ติดตั้งแพ็กเกจ OS ใหม่หรือเขียน config บริการ VPN ที่ถูกสร้างไว้บนเครื่องทับใหม่
- SlowDNS รุ่นเก่าบางไฟล์ยังดาวน์โหลด runtime จาก repository `hopp` ภายนอก และส่วนเสริมจาก repository ภายนอกยังคงใช้ URL ของแหล่งต้นทาง เพราะไม่ใช่ไฟล์ใน repository `hop` ที่กำลังตั้งค่า
- Cloudflare automation ใช้งานไม่ได้จนกว่าจะกรอก `PROJECT_CLOUDFLARE_DOMAIN`, `PROJECT_CLOUDFLARE_EMAIL` และ `PROJECT_CLOUDFLARE_API_KEY` เองใน `config.env` ค่า API key/email เก่าที่ฝังในไฟล์ถูกเอาออกแล้ว
- ยังไม่ได้รันบน VPS Debian/Ubuntu จริง จึงยังไม่ได้ยืนยันพฤติกรรม install, update, UDP traffic, uninstall และการเข้ากันได้ของแพ็กเกจตามแต่ละรุ่น
- GitHub ปฏิเสธไฟล์ rclone เดิมเพราะมี OAuth token; ชุดนี้ใช้ template ที่ไม่มี credential แล้ว แต่การ commit เก่าบน repository อาจยังเก็บสำเนาไว้ในประวัติ Git และควรเพิกถอน/หมุน token นั้น
