# Tasks — Tavern of Twilight

## Active (2-week sprint: farm → capture → sell)

- [x] **ยืนยันสถานะของระบบ farm ที่มีอยู่** - เช็คว่า crop.gd/farm_tile.gd ครบ loop till→plant→water→harvest จริงหรือยัง
- [x] **เพิ่มชนิดพืชให้มากกว่า wheat** - ตอนนี้มีแค่ resources/Crops/wheat.tres อันเดียว ต้องมีอย่างน้อย 2-3 ชนิดตาม GDD
- [ ] **ระบบจับมอนสเตอร์ (monster capture)** - core loop (wander, capture area, กด E จับ, MonsterPen เก็บของ) ทำงานแล้ว + มี prompt "กด E" โชว์เวลาเข้าใกล้พอ
  - [ ] ตอนจับพลาด (escape) มีแค่ print() ยังไม่มี feedback ให้ผู้เล่นเห็นจริง (popup/animation/เสียง)
  - [ ] `monster_id` ของ Mon_test.tscn ยังเป็น "slime" default ทั้งที่ sprite เปลี่ยนเป็น Boar แล้ว — เช็คว่าตั้งใจหรือ typo ค้าง
- [ ] **จุดขายของ (sell point)** - ตัดสินใจก่อนว่าจะขายให้ NPC vendor (ง่ายกว่า) หรือขายที่ร้านตัวเอง แล้วค่อยต่อกับ money_manager.gd ที่มีอยู่แล้ว
- [ ] **ต่อ UI พื้นฐาน** - inventory + ปุ่ม/หน้าจอขายของ ให้ผู้เล่นเห็นผลของ money_manager
  - [x] HUD component scripts (coin/day/time/hotbar) sync กับ manager แล้ว — ดู "Done" ด้านล่าง
  - [x] Inventory bag panel ต่อกับข้อมูลจริงแล้ว (สร้าง slot จาก Inventory.items อัตโนมัติ, ไม่ต้องลาก resource เองทีละช่อง)
  - [x] Drag & drop จาก bag → hotbar ใช้ได้แล้ว (ลากไอเทมจาก bag ไปวางบน hotbar slot เรียก set_hotbar_slot() ให้อัตโนมัติ)
  - [x] ปุ่ม "press I" เปิด/ปิด inventory panel จริงแล้ว (toggle ผ่าน inventory.gd)
  - [ ] carrot.tres / tomato.tres ยังไม่มี icon (ไม่มีไฟล์รูปแยกใน Assets/environment/ ต้องหา/ตัดรูปมาใส่ก่อน)
  - [ ] interaction_HUD.tscn ยังไม่ได้ต่อเข้า HUD.tscn หรือ scene ไหนเลย (VendorNPC ใช้ PromptLabel ของตัวเองแยกต่างหาก) — ตัดสินใจว่าจะรวมเป็นระบบเดียวไหม

## Waiting On

- [ ] **แบ่งงาน 3 คนให้ชัด** - รายงานล่าสุดมีชื่อ 3 คน (ศรัณยู/ธันว์/ทีชานนท์) แต่ที่คุยกันไว้แบ่งงานแค่ 2 ระบบ (Farm / Tavern) รอ confirm ว่าคนที่ 3 รับผิดชอบส่วนไหน

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
