# Trip Planner — CLAUDE.md

## Tổng quan
Web app lịch trình du lịch Thanh Đảo (Qingdao) 23–27/4/2026.
Single HTML file (`index.html`) + Supabase backend (project ref: `sfmwerurddclcttziweu`).


## Nguyên tắc làm việc
- **KHÔNG bịa thông tin** nếu không chắc (số tuyến, giờ tàu, địa chỉ...) — nói thẳng, hỏi user
- Tọa độ dùng **WGS-84** (Google Maps). Extract từ URL: `!3d<lat>!4d<lng>`
- Không xóa data mà không confirm
- Không thay đổi ngoài phạm vi được yêu cầu
- Khi swap days: phải swap stops, trows VÀ metadata (title, description, map_*) trong bảng days
