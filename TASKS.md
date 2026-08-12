# Tasks — Tavern of Twilight

## Active (2-week sprint: farm → capture → sell)

- [x] **ยืนยันสถานะของระบบ farm ที่มีอยู่** - เช็คว่า crop.gd/farm_tile.gd ครบ loop till→plant→water→harvest จริงหรือยัง
- [x] **เพิ่มชนิดพืชให้มากกว่า wheat** - ตอนนี้มีแค่ resources/Crops/wheat.tres อันเดียว ต้องมีอย่างน้อย 2-3 ชนิดตาม GDD
- [ ] **ระบบจับมอนสเตอร์ (monster capture)** - ยังไม่มีไฟล์ script ที่เกี่ยวข้องเลย ต้องเริ่มจากศูนย์
- [ ] **จุดขายของ (sell point)** - ตัดสินใจก่อนว่าจะขายให้ NPC vendor (ง่ายกว่า) หรือขายที่ร้านตัวเอง แล้วค่อยต่อกับ money_manager.gd ที่มีอยู่แล้ว
- [ ] **ต่อ UI พื้นฐาน** - inventory + ปุ่ม/หน้าจอขายของ ให้ผู้เล่นเห็นผลของ money_manager

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
