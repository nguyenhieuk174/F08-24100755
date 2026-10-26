# F08 · Sơ đồ hệ thống (System Diagram)

---

## 1. Bối cảnh ứng dụng — trục quay máy in 3D mini

Charter mục 1: *"Khối điều khiển động cơ bước cho trục quay của máy in 3D mini."*

```
   MIỀN SỐ (trong chip)          │  CÔNG SUẤT      │   THẾ GIỚI VẬT LÝ
 ═══════════════════════════════════════════════════════════════════════════════
                                  │                │
 ┌──────────────────────────┐     │                │
 │  Bộ sinh quỹ đạo /       │     │                │
 │  thông dịch G-code       │     │                │
 │  (CPU hoặc khối số khác) │     │                │
 └────┬────┬────┬───────┬───┘     │                │
      │    │    │       │         │                │
    run  dir  half   speed_div    │                │
      │    │  _step     │         │                │
      ▼    ▼    ▼       ▼         │                │
 ╔══════════════════════════════╗ │                │
 ║   ███  KHỐI F08  ███         ║ │                │
 ║   FSM vị trí trong chuỗi     ║ │                │
 ║   + bộ chia tần speed_div    ║ │                │
 ║   + bảng tra giải mã pha     ║ │                │
 ╚═════════╤═══════════╤════════╝ │                │
           │           │          │                │
     coil[3:0]   state_dbg[2:0]   │                │
           │           │          │                │
           ▼           ▼          │                │
      ┌────────────┐  (gỡ lỗi)    │                │
      │            │──────────────┼─┐              │
      │  ⬛ DRIVER │              │ │ 4 nửa cầu H  │
      │  CÔNG SUẤT │              │ │              │
      │  (A4988,   │──────────────┼─┼──▶ ┌──────────────┐
      │   DRV8825, │              │ │    │ ĐỘNG CƠ BƯỚC │
      │   cầu H…)  │──────────────┼─┼──▶ │  4 pha       │
      │            │              │ │    └──────┬───────┘
      │  NGOÀI     │──────────────┼─┘           │
      │  PHẠM VI   │              │             ▼
      └────────────┘              │       ┌──────────────┐
                                  │       │ Trục vít me  │
                                  │       │ → đầu in     │
                                  │       └──────────────┘
                                  │             │
                                  │             ▼
                                  │      ❌ KHÔNG CÓ ENCODER
                                  │      (Charter mục 3: phản hồi
                                  │       vị trí ngoài phạm vi)
```

### 1.1 Điều sơ đồ này làm rõ: **vòng điều khiển là vòng HỞ**

Không có encoder, không có phản hồi vị trí. Hệ quả là toàn bộ lý do tồn tại của phần khó
nhất trong F08:

| Hệ quả của vòng hở | Chi tiết |
|---|---|
| **Mỗi bước bị mất là mất vĩnh viễn** | Không có cơ chế nào phát hiện và sửa. Phần mềm nghĩ đầu in ở `x = 10,0 mm`; thực tế nó ở `9,7 mm`. |
| **Sai lệch tích luỹ** | Lỗi cộng dồn qua mỗi lần đổi chiều, không tự triệt tiêu |
| Chính vì vậy `f08_bad_direction_reset` **rất nguy hiểm** | Nó làm mất tới **7 bước** mỗi lần đổi chiều (xem `fsm.md` §8.2). Trên máy in 3D, sau vài chục lần đảo chiều, bản in méo hẳn. |
| Và vì vậy **INV-4 quan trọng hơn mọi invariant khác** | *"Mỗi nhịp làm `s` đổi đúng 1 đơn vị"* — và invariant này **chưa có ở bất kỳ đâu** trong gói. Xem `corner_cases.md` §1.2. |

Đây là ví dụ rõ nhất về việc **bối cảnh ứng dụng quyết định thứ tự ưu tiên kiểm chứng**:
cùng một FSM đếm vòng, nếu có encoder thì lỗi mất bước là phiền toái; không có encoder thì
đó là lỗi chí mạng.

## 2. Ranh giới khối

| Hạng mục | Thuộc F08? | Ai lo |
|---|:-:|---|
| Giữ vị trí trong chuỗi | ✅ | F08 (`state[2:0]`) |
| Tiến/lùi vị trí theo `dir` | ✅ | F08 |
| Chọn chuỗi 4 hay 8 bước | ✅ | F08 (`half_step`) |
| Chia tần để đặt tốc độ | ✅ | F08 (`div_count`, `speed_div`) |
| Giải mã vị trí → mẫu 4 pha | ✅ | F08 (`phase_decode`) |
| Ngắt dòng khi dừng | ✅ | F08 (`coil = run ? … : 0`) |
| **Khuếch đại công suất, điều dòng** | ❌ ⬛ **analog/công suất** | Driver ngoài — Charter mục 3 ngoài phạm vi |
| **Vi bước** | ❌ | Ngoài phạm vi (Charter mục 3) |
| **Gia tốc, đường cong tốc độ** | ❌ | Bộ sinh quỹ đạo tầng ngoài |
| **Phản hồi vị trí** | ❌ **và không tồn tại** | Ngoài phạm vi — xem §1.1 |
| Chọn `speed_div` | ❌ | Tầng ngoài. ⚠️ Charter mục 4 **không cấp chân** cho nó |
| Bảo vệ quá dòng / quá nhiệt | ❌ | Driver |

### 2.1 Nghĩa vụ hợp đồng của tầng ngoài

| # | Nghĩa vụ | Nếu vi phạm |
|---|---|---|
| 1 | `dir`, `half_step`, `run` đồng bộ với `clk` | Metastability; nặng hơn — đổi `dir` gần cạnh clock có thể làm bước đi sai hướng |
| 2 | **Không đổi `half_step` khi `s ≥ 4`** | FSM vào **vùng tàn dư**; `coil` bị ép về `1001`; rotor có thể giật. Xem `fsm.md` §6.2. |
| 3 | `speed_div` đủ lớn để động cơ theo kịp | Mất bước **vật lý** — F08 không biết và không thể biết |
| 4 | `rst_n` giữ ≥ 1 chu kỳ khi clock đang chạy (reset **đồng bộ**) | F08 không được khởi tạo |
| 5 | Sau reset, tầng ngoài phải **giả định vị trí = 0** và thực hiện homing | F08 đặt `s = 0` nhưng rotor **ở đâu thì ở đó** — phần mềm và phần cứng lệch nhau ngay từ đầu |

> Nghĩa vụ **số 5** hay bị bỏ qua nhất và là hệ quả trực tiếp của vòng hở: `rst_n` đặt lại
> **biến đếm**, không đặt lại **trục máy**. Mọi máy in 3D thật vì vậy đều có quy trình
> homing bằng công tắc giới hạn — nằm hoàn toàn ngoài F08.

## 3. Phân loại — analog / digital / mixed

| Thành phần | Phân loại |
|---|---|
| Bộ sinh quỹ đạo, F08 | **Digital đồng bộ** |
| Driver công suất (cầu H, điều dòng) | **Analog / công suất** — ⬛ ngoài phạm vi |
| Động cơ, trục vít me | Cơ điện |
| Toàn hệ thống | **Mixed-signal + cơ điện** |
| **Phần phải phân tích (F08)** | **Thuần digital** |

Bằng chứng F08 là digital tuần tự thuần: `synth_stat.txt` chỉ có standard cell
`sky130_fd_sc_hd`, `Number of memories: 0`; `power_report.txt` cho `Macro 0.0%`, `Pad 0.0%`.

## 4. Vòng đời RTL → GDSII — trạng thái theo CI run

Run mới nhất `RUN_2026-10-26_05-07-08`; archive và log trong [`../06_GDSII/`](../06_GDSII/).

```
 ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
 │ Đặc tả      │──▶│ RTL         │──▶│ Mô phỏng    │──▶│ Tổng hợp    │
 │ (Charter)   │   │ .sv         │   │ hành vi     │   │ Yosys       │
 │     ✅      │   │     ✅      │   │  ✅ PASS    │   │     ✅      │
 │             │   │             │   │  Icarus     │   │             │
 └─────────────┘   └─────────────┘   └──────┬──────┘   └──────┬──────┘
                                            │                 │
                              known_issues.md│                 │ netlist.v
                              (lỗi TESTBENCH)│                 ▼
 ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
 │ STA         │──▶│ Công suất   │──▶│ Floorplan   │──▶│ Placement   │
 │ OpenROAD    │   │ OpenROAD    │   │ LibreLane   │   │ LibreLane   │
 │     ✅      │   │     ✅      │   │     ✅      │   │     ✅      │
 └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘
                                                              │
 ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌──────┴──────┐
 │ GDS         │◀──│ LVS         │◀──│ DRC         │◀──│ CTS + Route │
 │     ✅      │   │     ✅      │   │     ✅      │   │     ✅      │
 └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘

 ⬛ KHÔNG ÁP DỤNG (Charter mục 3):
    vi bước · điều khiển dòng · gia tốc · phản hồi vị trí ·
    analog transistor · physical design tự làm · sign-off · tape-out · chế tạo
```

### 4.1 Lịch sử chẩn đoán trước khi vá và chạy CI

Nội dung dưới đây ghi lại trạng thái cũ khi testbench chưa biên dịch và tổng hợp nhầm module; không dùng các kết luận này làm trạng thái hiện tại. Trạng thái hiện tại: RTL simulation PASS; archive LibreLane có GDS, P&R, DRC/LVS. Gate-level/SDF simulation chưa có bằng chứng. Xem [`../06_GDSII/physical_report.md`](../06_GDSII/physical_report.md).

Ở trạng thái lịch sử đó, chuỗi bằng chứng bị đứt ở hai chỗ:

```
  ĐỨT 1 — không có bằng chứng hành vi nào:
      Mô phỏng ──▶ f08_stepper_ctrl        ❌ COMPILE_FAIL (0 chu kỳ chạy)
                                              └─ lỗi TESTBENCH, known_issues.md

  ĐỨT 2 — tổng hợp nhầm module:
      Tổng hợp ──▶ f08_bad_direction_reset  ✅ PASS  (22 cell · 4 FF · 190,1824 µm²)
                   └── PHẢN VÍ DỤ, không phải bộ điều khiển động cơ bước
                       (synth.ys dòng 5)
```

| | `f08_stepper_ctrl` (thiết kế đúng) | `f08_bad_direction_reset` (được đo) |
|---|---|---|
| Có bằng chứng hành vi? | ❌ **không một chu kỳ nào** | ❌ không (không có TB riêng) |
| Có bằng chứng cấu trúc? | ❌ chưa tổng hợp | ✅ 22 cell, 4 FF, 190,1824 µm² |
| Có `coil`, `run`, `half_step`? | ✅ | ❌ |
| Đổi chiều đúng? | ✅ (đọc từ mã, **chưa chạy**) | ❌ mất bước |

⟹ **Không được nói "F08 đã được kiểm chứng" hay "F08 tốn 22 cell".** Câu đúng là: *một
phản ví dụ trong gói F08 đã được tổng hợp và đo; bộ điều khiển thật chưa từng được tổng hợp
và chưa từng chạy được một chu kỳ mô phỏng nào.*

So với hai đề cùng nhóm:

| Đề | Mô phỏng | Tổng hợp đúng module? | Chuỗi bằng chứng |
|---|---|---|---|
| F06 | ✅ PASS (`f06_debounce`) | ❌ tổng hợp phản ví dụ | Đứt 1 chỗ |
| F07 | ⚠️ FATAL t=156, nhưng 11 assertion PASS | ✅ đúng module | **Liền mạch** |
| **F08** | ❌ **COMPILE_FAIL** | ❌ tổng hợp phản ví dụ | **Đứt 2 chỗ** |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
