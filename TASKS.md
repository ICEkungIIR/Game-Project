# Tasks — Tavern of Twilight

## Active (2-week sprint: farm → capture → sell)

- [x] **ยืนยันสถานะของระบบ farm ที่มีอยู่** - เช็คว่า crop.gd/farm_tile.gd ครบ loop till→plant→water→harvest จริงหรือยัง
- [x] **เพิ่มชนิดพืชให้มากกว่า wheat** - ตอนนี้มีแค่ resources/Crops/wheat.tres อันเดียว ต้องมีอย่างน้อย 2-3 ชนิดตาม GDD
- [ ] **ระบบจับมอนสเตอร์ (monster capture)** - core loop (wander, capture area, กด E จับ, MonsterPen เก็บของ) ทำงานแล้ว + มี prompt "กด E" โชว์เวลาเข้าใกล้พอ
  - [ ] ตอนจับพลาด (escape) มีแค่ print() ยังไม่มี feedback ให้ผู้เล่นเห็นจริง (popup/animation/เสียง)
  - [x] `monster_id` ของ Mon_test.tscn ยังเป็น "slime" default ทั้งที่ sprite เปลี่ยนเป็น Boar แล้ว — เช็คว่าตั้งใจหรือ typo ค้าง
- [x] **จุดขายของ (sell point)** - ตัดสินใจแล้ว: ขายให้ NPC vendor (NPC_vender.tscn ต่อ SellUI.gd ต่อ Money แล้ว, ทำงานได้จริงใน world.tscn — กด E ที่ vendor เปิด sell UI, ขายทีละชนิดหรือขายหมดทีเดียว)
- [x] **ระบบ plant/growth/harvest จริง** - ต่อเข้ากับ FarmManager (Farm autoload) แล้ว: เลือกพืชใน hotbar → กด E บนดินที่ไถแล้วเพื่อปลูก (หัก item 1 ชิ้น), รดน้ำต่อพืชที่ปลูกแล้วให้โตนับวันจาก TimeM.day_started, สไปรท์พืชโชว์จริงในทุ่ง (ใช้ icon เดิมของแต่ละพืช สเกลขึ้นตามวันที่โต — รอ art ระยะการโตจริงทีหลัง), กด E ตอนพืชพร้อมเก็บเกี่ยวเพื่อ harvest คืน item เข้า inventory และดินกลับเป็น tilled ให้ปลูกใหม่ได้ทันที; มีปุ่ม debug K = ข้ามวัน (TimeM.next_day()) ไว้เทสการโตเร็วๆ
- [ ] **ต่อ UI พื้นฐาน** - inventory + ปุ่ม/หน้าจอขายของ ให้ผู้เล่นเห็นผลของ money_manager
  - [x] HUD component scripts (coin/day/time/hotbar) sync กับ manager แล้ว — ดู "Done" ด้านล่าง
  - [x] Inventory bag panel ต่อกับข้อมูลจริงแล้ว (สร้าง slot จาก Inventory.items อัตโนมัติ, ไม่ต้องลาก resource เองทีละช่อง)
  - [x] Drag & drop จาก bag → hotbar ใช้ได้แล้ว (ลากไอเทมจาก bag ไปวางบน hotbar slot เรียก set_hotbar_slot() ให้อัตโนมัติ)
  - [x] ปุ่ม "press I" เปิด/ปิด inventory panel จริงแล้ว (toggle ผ่าน inventory.gd)
  - [x] carrot.tres / tomato.tres มี icon แล้ว (ตัดจาก Assets/resources/Crops/crop_seed.png ด้วย AtlasTexture)
  - [ ] interaction_HUD.tscn ยังไม่ได้ต่อเข้า HUD.tscn หรือ scene ไหนเลย (VendorNPC ใช้ PromptLabel ของตัวเองแยกต่างหาก) — ตัดสินใจว่าจะรวมเป็นระบบเดียวไหม

## Waiting On

- [x] **แบ่งงาน 3 คนให้ชัด** - confirm แล้ว (ศรัณยู/ธันว์/ทีชานนท์)

## Someday (full-vision จากรายงาน — ยังไม่อยู่ใน 2-week sprint)

- [ ] Combat system (attack/skill ผ่าน LMB-J / RMB-K)
- [ ] Skill Tree (ปุ่ม C)
- [ ] ตกปลา
- [ ] NPC นักผจญภัย 5 อาชีพ พร้อมนิสัย/อาหารเฉพาะตัว
- [ ] มอนสเตอร์ 3 ชนิด (Slime/Goblin/Wolf) พร้อมระบบ drop item
- [ ] ปริศนาและกับดัก (ยังไม่ได้กำหนดขอบเขต — ต้องตัดสินใจว่าจะทำไหม)
- [ ] Day-night cycle ที่มีผลต่อ gameplay
- [ ] Quest system
- [ ] Save/load
- [ ] แคปหน้าจอเกม + คำอธิบาย ใส่ในรายงาน (ข้อ 7 ด่าน/ฉาก)

## Done
