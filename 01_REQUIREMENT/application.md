# F08 · Bối cảnh ứng dụng

> 🔧 **ĐỀ NÀY ĐÃ ĐƯỢC VÁ LỖI**
>
> Mô phỏng ban đầu không đạt. Lỗi đã được chẩn đoán, vá và **xác minh lại bằng
> công cụ thật**. Mọi số liệu trong hồ sơ là số liệu **sau khi vá**.
>
> * Mã nguồn gốc: [`08_ORIGINAL_SOURCE/`](08_ORIGINAL_SOURCE/) — giữ nguyên, quay lui được
> * Nhật ký vá: [`08_ORIGINAL_SOURCE/PATCHLOG.md`](08_ORIGINAL_SOURCE/PATCHLOG.md)
> * Chẩn đoán đầy đủ: [`05_VERIFICATION/known_issues.md`](05_VERIFICATION/known_issues.md)



| | |
|---|---|
| Mã đề | **F08** |
| Tên đề | FSM điều khiển động cơ bước |
| Nhóm đề | F · Máy trạng thái hữu hạn (FSM) |
| Độ khó | Trung bình |
| Loại mạch | **Tuần tự** |
| Quy mô ước lượng (Charter) | ~150–220 cell · 1×1 tile |
| Nguồn gốc | Project Charter — F08, mục 1 |

---

## 1. Mục tiêu và bối cảnh ứng dụng

Trích nguyên văn Charter mục 1:

> Phân tích khối số “FSM điều khiển động cơ bước” ở mức khối. Bối cảnh ứng dụng: Khối điều khiển động cơ bước cho trục quay của máy in 3D mini.

## 2. Vị trí khối F08 trong hệ thống

```
   ┌──────────────┐      ┌──────────────────────────────┐      ┌──────────────┐
   │  Nguồn tín   │─────▶│      ►►► KHỐI F08 ◄◄◄        │─────▶│  Tầng tiêu   │
   │  hiệu / dữ   │      │  FSM điều khiển động cơ bước  │      │  thụ kết quả │
   │  liệu vào    │      │  Loại mạch: Tuần tự          │      │              │
   └──────────────┘      └──────────────────────────────┘      └──────────────┘
```

> Sơ đồ chi tiết có chú thích: `03_ARCHITECTURE/system_diagram.md`.

## 3. Phân loại analog / digital / mixed

| Khối | Phân loại | Ghi chú |
|---|---|---|
| Cảm biến / nguồn tín hiệu vật lý (nếu có) | Analog | Đại lượng liên tục |
| Chuyển đổi ADC/DAC (nếu có) | Mixed-signal | Ranh giới analog–số |
| **F08 — FSM điều khiển động cơ bước** | **Digital, tuần tự** | Có ô nhớ, hoạt động theo cạnh clock |
| Tầng xử lý phía sau | Digital | Tiêu thụ kết quả của F08 |

Bằng chứng cho dòng phân loại của F08: LibreLane ghi nhận **15 flip-flop** trong
[`06_GDSII/runs/RUN_2026-10-26_05-07-08/final/metrics.json`](../06_GDSII/runs/RUN_2026-10-26_05-07-08/final/metrics.json).

---

**Truy vết:** yêu cầu sinh từ tài liệu này được đánh số `REQ-F08-0xx` trong
`01_REQUIREMENT/requirements.md`, và truy vết đến bằng chứng trong `07_TRACEABILITY/RTM.csv`.

*Phiên bản: v1.0 · Ngày: 2026-09-24*
