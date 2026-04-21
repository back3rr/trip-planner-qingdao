-- ══════════════════════════════════════════════
-- SCHEMA
-- ══════════════════════════════════════════════
create table if not exists trips (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  subtitle   text not null,
  created_at timestamptz default now()
);

create table if not exists days (
  id          uuid primary key default gen_random_uuid(),
  trip_id     uuid references trips(id) on delete cascade,
  day_key     text not null,
  sort_order  int  not null,
  label       text not null,
  title       text not null,
  description text,
  color       text not null,
  map_zoom    int  not null,
  map_center  jsonb not null,
  gmap_url    text
);

create table if not exists stops (
  id            uuid primary key default gen_random_uuid(),
  day_id        uuid references days(id) on delete cascade,
  stop_number   int  not null,
  section_label text,
  lat           numeric(10,7) not null,
  lng           numeric(10,7) not null,
  name          text not null,
  chinese_name  text,          -- actual Chinese name/address (secondary subtitle)
  time_label    text,
  note          text,          -- Vietnamese description (may contain safe HTML like <b>)
  gmap_url      text,
  badges        jsonb default '[]'
);

create table if not exists trows (
  id         uuid primary key default gen_random_uuid(),
  day_id     uuid references days(id) on delete cascade,
  after_stop int  not null,
  content    text not null
);

-- ══════════════════════════════════════════════
-- RLS
-- ══════════════════════════════════════════════
alter table trips  enable row level security;
alter table days   enable row level security;
alter table stops  enable row level security;
alter table trows  enable row level security;

drop policy if exists "public read" on trips;
drop policy if exists "public read" on days;
drop policy if exists "public read" on stops;
drop policy if exists "public read" on trows;

create policy "public read" on trips  for select using (true);
create policy "public read" on days   for select using (true);
create policy "public read" on stops  for select using (true);
create policy "public read" on trows  for select using (true);

-- ══════════════════════════════════════════════
-- SEED
-- ══════════════════════════════════════════════
DO $$
DECLARE
  trip_id uuid;
  d23_id  uuid;
  d24_id  uuid;
  d25_id  uuid;
  d26_id  uuid;
  d27_id  uuid;
BEGIN

-- Clean up any previous seed run
DELETE FROM trows;
DELETE FROM stops;
DELETE FROM days;
DELETE FROM trips;

INSERT INTO trips (name, subtitle)
VALUES ('Thanh Đảo 青島', '23–27 tháng 4, 2026 · Gia đình')
RETURNING id INTO trip_id;

-- ── DAYS ──────────────────────────────────────
INSERT INTO days (trip_id,day_key,sort_order,label,title,description,color,map_zoom,map_center,gmap_url)
VALUES (trip_id,'23',1,'Ngày 1 · Thứ 5','Dạo quanh KS',
  'Nghỉ ngơi rồi đi bộ các điểm gần Manxin. Hoàng hôn đầu tiên ở Trạm Kiều.',
  '#4a9eff',15,'{"lat":36.067,"lng":120.322}',
  'https://www.google.com/maps/dir/36.07202,120.32094/36.072938,120.324322/36.0673,120.320634/36.058454,120.320491')
RETURNING id INTO d23_id;

INSERT INTO days (trip_id,day_key,sort_order,label,title,description,color,map_zoom,map_center,gmap_url)
VALUES (trip_id,'24',2,'Ngày 2 · Thứ 6','Trục Đông',
  'Sa Tử Khẩu sớm → về dần trung tâm. Hoàng hôn Olympic.',
  '#2ecc8a',12,'{"lat":36.09,"lng":120.47}',
  'https://www.google.com/maps/dir/36.07202,120.32094/36.11347,120.54345/36.054446,120.431213/36.060096,120.390406')
RETURNING id INTO d24_id;

INSERT INTO days (trip_id,day_key,sort_order,label,title,description,color,map_zoom,map_center,gmap_url)
VALUES (trip_id,'25',3,'Ngày 3 · Thứ 7','Old Town Deep Dive',
  'Tây → Đông: Tây Lăng sáng sớm, xuyên Old Town, Bát Đại Quan chiều. Hoàng hôn #1 tại Cầm Dữ.',
  '#ff7c4a',15,'{"lat":36.059,"lng":120.331}',
  'https://www.google.com/maps/dir/36.07202,120.32094/36.05716,120.31044/36.0598699,120.31254/36.06065,120.31324/36.0637221,120.3229157/36.06216,120.32904/36.0625,120.33051/36.062511,120.331795/36.05982,120.3371/36.05885,120.33654/36.052201,120.352919/36.05395,120.3304/36.052805,120.324005')
RETURNING id INTO d25_id;

INSERT INTO days (trip_id,day_key,sort_order,label,title,description,color,map_zoom,map_center,gmap_url)
VALUES (trip_id,'26',4,'Ngày 4 · Chủ nhật','Tế Nam Day Trip',
  'Không có lịch Qingdao — khám phá Tế Nam (济南).',
  '#f5c842',13,'{"lat":36.66,"lng":117.0}',
  'https://www.google.com/maps/search/济南/@36.6512,117.1201,13z')
RETURNING id INTO d26_id;

INSERT INTO days (trip_id,day_key,sort_order,label,title,description,color,map_zoom,map_center,gmap_url)
VALUES (trip_id,'27',5,'Ngày 5 · Thứ 2','Cáp treo + Bia + Chia tay',
  'Cáp treo ngắm hoa, bia Tsingtao tươi, mua quà, hoàng hôn chia tay. Bay 22:00.',
  '#c97fff',14,'{"lat":36.067,"lng":120.335}',
  'https://www.google.com/maps/dir/36.07202,120.32094/36.065131,120.355922/36.07912,120.346834/36.070931,120.318702/36.0709,120.319/36.058454,120.320491')
RETURNING id INTO d27_id;

-- ══════════════════════════════════════════════
-- N1 STOPS · 23/4
-- chinese_name = Chinese address/name; note = Vietnamese description
-- ══════════════════════════════════════════════
INSERT INTO stops
  (day_id, stop_number, section_label, lat, lng, name, chinese_name, time_label, note, gmap_url, badges)
VALUES
  (d23_id, 1, 'Chiều',
   36.0720200, 120.3209400,
   'KS Manxin Zhanqiao',
   '曼信酒店栈桥 · 158 Jiaozhou Rd',
   '14:00 · Check-in',
   'Metro Line 3 ngay cạnh. Rooftop nổi tiếng.',
   'https://www.google.com/maps/search/曼信酒店栈桥/@36.07202,120.32094,17z',
   '[{"type":"bx","text":"🚕 Từ sân bay ~1h"}]'),

  (d23_id, 2, null,
   36.0729380, 120.3243220,
   'Đảo Đại Bảo',
   '大鲍岛即墨路小商品市场',
   '15:00 · 60 phút',
   'Khu phố cổ: graffiti wall + cafe + chợ Jimo.',
   'https://www.google.com/maps/search/大鲍岛即墨路小商品市场/@36.072938,120.324322,17z',
   '[{"type":"bf","text":"Miễn phí"}]'),

  (d23_id, 3, null,
   36.0673000, 120.3206340,
   'Nhà thờ St. Michael',
   '圣弥厄尔教堂 · 15 Zhejiang Road',
   '16:00 · 60 phút',
   'Gothic 2 tháp chuông 56m. <b>Đóng thứ Hai</b> nhưng chụp ngoài được.',
   'https://www.google.com/maps/search/圣弥厄尔教堂/@36.0673,120.320634,17z',
   '[{"type":"bt","text":"🎫 10 NDT vào trong"}]'),

  (d23_id, 4, null,
   36.0584540, 120.3204910,
   'Trạm Kiều',
   '栈桥 · 14 Taiping Road',
   '17:30 · ★ HOÀNG HÔN',
   'Cầu tàu 440m + Huilan Pavilion. Mặt trời lặn ~18:40.',
   'https://www.google.com/maps/search/栈桥/@36.058454,120.320491,17z',
   '[{"type":"bs","text":"🌅 Hoàng hôn 18:40"},{"type":"bf","text":"Miễn phí"}]');

-- N1 TROWS
INSERT INTO trows (day_id, after_stop, content) VALUES
  (d23_id, 1, '🚶 250m hướng Đông'),
  (d23_id, 2, '🚶 500m hướng Nam'),
  (d23_id, 3, '🚶 1.2km xuống biển');

-- ══════════════════════════════════════════════
-- N2 STOPS · 24/4
-- ══════════════════════════════════════════════
INSERT INTO stops
  (day_id, stop_number, section_label, lat, lng, name, chinese_name, time_label, note, gmap_url, badges)
VALUES
  (d24_id, 1, 'Sáng',
   36.1134700, 120.5434500,
   'Sa Tử Khẩu',
   '沙子口广场 · Laoshan',
   '09:00 · 3 tiếng · ★ MANDATORY',
   '"Amalfi của Trung Quốc". Đứng phía Nam chụp về Bắc.',
   'https://www.google.com/maps/search/沙子口广场/@36.11347,120.54345,17z',
   '[{"type":"bm","text":"⭐ Không thể bỏ"},{"type":"bx","text":"🚗 ~600 NDT cả ngày"}]'),

  (d24_id, 2, 'Chiều',
   36.0544460, 120.4312130,
   'Tiểu Mạch Đảo',
   '小麦岛公园',
   '14:30 · 2 tiếng',
   'Đảo Ghibli — lawn xanh, cây trái tim.',
   'https://www.google.com/maps/search/小麦岛公园/@36.054446,120.431213,17z',
   '[{"type":"bf","text":"Miễn phí"}]'),

  (d24_id, 3, null,
   36.0600960, 120.3904060,
   'Trung tâm Olympic',
   '奥帆中心',
   '16:45 · ★ HOÀNG HÔN',
   'Light show ~18:30. Mặt trời lặn ~18:40.',
   'https://www.google.com/maps/search/奥帆中心/@36.060096,120.390406,17z',
   '[{"type":"bs","text":"🌅 Hoàng hôn + Light show"},{"type":"bf","text":"Miễn phí"}]');

-- N2 TROWS
INSERT INTO trows (day_id, after_stop, content) VALUES
  (d24_id, 1, '🚕 ~20 phút về trung tâm'),
  (d24_id, 2, '🚕 15 phút');

-- ══════════════════════════════════════════════
-- N3 STOPS · 25/4
-- Note: stops 1–8,11–12 have Chinese embedded in name → chinese_name=null
--       description goes into note field
-- ══════════════════════════════════════════════
INSERT INTO stops
  (day_id, stop_number, section_label, lat, lng, name, chinese_name, time_label, note, gmap_url, badges)
VALUES
  -- Sáng · Tây Lăng
  (d25_id, 1, 'Sáng · Tây Lăng',
   36.0571600, 120.3104400,
   'Tây Lăng Hiệp 3', '西陵峡三路',
   '09:00 · ★ Little Kamakura',
   'Blue railings + biển. Red No Entry sign viral.',
   'https://www.google.com/maps/search/西陵峡三路/@36.05716,120.31044,17z',
   '[{"type":"bm","text":"📸 Spot viral · ánh sáng sáng đẹp"}]'),

  (d25_id, 2, null,
   36.0598699, 120.3125400,
   'Tây Lăng Hiệp 1', '西陵峡一路',
   '09:35 · 20p',
   'Miyazaki + mái nhà đỏ + biển.',
   'https://www.google.com/maps/search/西陵峡一路/@36.0598699,120.31254,17z',
   '[]'),

  (d25_id, 3, null,
   36.0606500, 120.3132400,
   'Công viên Lý Úy Nông', '李慰农公园',
   '10:00 · 20p',
   '2 cây thông foreground chụp Trạm Kiều.',
   'https://www.google.com/maps/search/李慰农公园/@36.06065,120.31324,17z',
   '[]'),

  -- Trưa · Old Town
  (d25_id, 4, 'Trưa · Old Town',
   36.0637221, 120.3229157,
   'Đường Juxian', '莒县路',
   '10:25 · 10p',
   'Châu Âu cổ điển ít người.',
   'https://www.google.com/maps/search/莒县路/@36.0637221,120.3229157,17z',
   '[]'),

  (d25_id, 5, null,
   36.0621600, 120.3290400,
   'Đường Changzhou', '常州路',
   '10:40 · café + ăn sáng muộn',
   'Kiến trúc Đông-Tây. Nghỉ café tại đây.',
   'https://www.google.com/maps/search/常州路/@36.06216,120.32904,17z',
   '[]'),

  (d25_id, 6, null,
   36.0625000, 120.3305100,
   'Đường Long Giang', '龙江路',
   '11:30 · 25p',
   'Graffiti wall Ghibli. Trẻ con rất thích.',
   'https://www.google.com/maps/search/龙江路/@36.0625,120.33051,17z',
   '[]'),

  (d25_id, 7, null,
   36.0625110, 120.3317950,
   'Nhà cũ Lão Xá', '老舍故居',
   '12:00 · 20p',
   'Nhà văn Lão Xá. <b>Đóng thứ Hai.</b>',
   'https://www.google.com/maps/search/老舍故居/@36.062511,120.331795,17z',
   '[]'),

  (d25_id, 8, null,
   36.0598200, 120.3371000,
   'Đường nhánh Phúc Sơn', '福山支路',
   '12:25 · 20p',
   'Kiến trúc Đức retro.',
   'https://www.google.com/maps/search/福山支路/@36.05982,120.3371,17z',
   '[]'),

  (d25_id, 9, null,
   36.0588500, 120.3365400,
   'Núi Tiểu Ngư',
   '小鱼山公园',
   '12:50 · ★ PANORAMA + ăn trưa',
   'Panorama #1 Qingdao. Lanchao Pavilion tầng 3.',
   'https://www.google.com/maps/search/小鱼山公园/@36.05885,120.33654,17z',
   '[{"type":"bt","text":"🎫 10–15 NDT"}]'),

  -- Chiều · Bát Đại Quan
  (d25_id, 10, 'Chiều · Bát Đại Quan',
   36.0522010, 120.3529190,
   'Bát Đại Quan',
   '八大关',
   '14:00 · 2.5 tiếng',
   'Biệt thự Nga/Đức/Đan/Thụy. Thuê xe điện cho trẻ.',
   'https://www.google.com/maps/search/八大关/@36.052201,120.352919,17z',
   '[{"type":"bf","text":"Miễn phí"}]'),

  -- Hoàng hôn
  (d25_id, 11, 'Hoàng hôn',
   36.0539500, 120.3304000,
   'Đường Cầm Dữ', '琴屿路',
   '17:00 · ★ HOÀNG HÔN #1',
   '<b>Hoàng hôn đẹp nhất Qingdao.</b> Mặt trời lặn 18:40.',
   'https://www.google.com/maps/search/琴屿路/@36.05395,120.3304,17z',
   '[{"type":"bs","text":"🌅 Đẹp nhất Qingdao"}]'),

  (d25_id, 12, null,
   36.0528050, 120.3240050,
   'Tiểu Thanh Đảo', '小青岛',
   '18:30 · 1 tiếng',
   'Hải đăng Đức 1900. <b>Đặt QR WeChat 魅力海滨 trước.</b>',
   'https://www.google.com/maps/search/小青岛/@36.052805,120.324005,17z',
   '[{"type":"bb","text":"📱 Đặt WeChat trước"},{"type":"bt","text":"~30 NDT"}]');

-- N3 TROWS
INSERT INTO trows (day_id, after_stop, content) VALUES
  (d25_id,  1, '🚶 350m dọc bờ biển'),
  (d25_id,  2, '🚶 100m hướng Bắc'),
  (d25_id,  3, '🚶 950m hướng Đông Bắc'),
  (d25_id,  4, '🚶 600m hướng Đông Nam'),
  (d25_id,  5, '🚶 150m hướng Đông'),
  (d25_id,  6, '🚶 100m hướng Đông'),
  (d25_id,  7, '🚶 550m hướng Đông Nam'),
  (d25_id,  8, '🚶 120m hướng Nam'),
  (d25_id,  9, '🚕 ~5 phút hướng Đông'),
  (d25_id, 10, '🚕 ~5 phút hướng Tây');

-- ── N4: no stops (special Jinan card rendered in JS) ───

-- ══════════════════════════════════════════════
-- N5 STOPS · 27/4
-- Chinese embedded in name → chinese_name=null; description → note
-- ══════════════════════════════════════════════
INSERT INTO stops
  (day_id, stop_number, section_label, lat, lng, name, chinese_name, time_label, note, gmap_url, badges)
VALUES
  (d27_id, 1, 'Sáng',
   36.0651310, 120.3559220,
   'Trung Sơn + Cáp treo', '中山公园',
   '09:00 · 2 tiếng',
   'Cáp treo lên Taiping Mountain. Hoa mướn + tulip.',
   'https://www.google.com/maps/search/中山公园/@36.065131,120.355922,17z',
   '[{"type":"bt","text":"🎫 ~120 NDT k/h"},{"type":"bf","text":"Công viên miễn phí"}]'),

  (d27_id, 2, 'Trưa',
   36.0791200, 120.3468340,
   'Bảo tàng bia Tsingtao', '青岛啤酒博物馆',
   '11:30 · 2.5 tiếng',
   'Bia tươi kèm vé. Ăn trưa tại đây. Hologram + drunk simulator.',
   'https://www.google.com/maps/search/青岛啤酒博物馆/@36.07912,120.346834,17z',
   '[{"type":"bt","text":"🎫 ~60–80 NDT"}]'),

  (d27_id, 3, 'Chiều · Mua quà',
   36.0709310, 120.3187020,
   'Phố Trung Sơn', '中山路商圈',
   '15:30 · ★ MUA QUÀ',
   'Bia Tsingtao lon · rong biển · hải sản khô.',
   'https://www.google.com/maps/search/中山路商圈/@36.070931,120.318702,17z',
   '[{"type":"bm","text":"🛍 Mua quà về"}]'),

  (d27_id, 4, null,
   36.0709000, 120.3190000,
   'Thượng Giới Lý', '上街里',
   '17:00 · 1 tiếng',
   'Phố đi bộ hiện đại. Tiếp tục mua sắm + ăn nhẹ.',
   'https://www.google.com/maps/search/上街里/@36.0709,120.319,17z',
   '[]'),

  (d27_id, 5, null,
   36.0584540, 120.3204910,
   'Trạm Kiều', '栈桥',
   '18:00 · ★ HOÀNG HÔN CHIA TAY',
   'Hoàng hôn chia tay Qingdao → KS lấy đồ → sân bay.',
   'https://www.google.com/maps/search/栈桥/@36.058454,120.320491,17z',
   '[{"type":"bs","text":"🌅 Chia tay"},{"type":"bx","text":"🚕 Sân bay ~20:00"}]');

-- N5 TROWS
INSERT INTO trows (day_id, after_stop, content) VALUES
  (d27_id, 1, '🚕 ~5 phút hướng Bắc'),
  (d27_id, 2, '🚕 ~8 phút hướng Tây'),
  (d27_id, 4, '🚶 1.4km hướng Nam');

END $$;
