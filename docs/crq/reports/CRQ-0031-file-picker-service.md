# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0031 |
| Title | Pick the sign-up photo and licence files as bytes, with the size limits checked on the device |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-28 |
| Date implemented | 2026-10-28 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Sign-up needs a profile photo (D1, E1, F1) and one or two licence files
(E2, F2). Theo supplied a picker service; I reviewed it and reshaped it to
what sign-up uploads.

1. **Dependencies:** `image_picker` (photo, camera or gallery) and
   `file_picker` 13 (licence documents), both chosen by Theo. Both install
   through Swift Package Manager on iOS, so no `Podfile` appears.
2. **`FilePickerService`** (`lib/core/services/`, injectable):
   - `pickPhoto(fromCamera:)` resizes on the device (longest side 1024,
     quality 85), so a camera photo stays well under the 3 MB rule; a photo
     still over it is refused with `fileTooLarge`; refused camera or photo
     access is `permissionDenied`.
   - `pickLicence()` accepts PDF, JPG or PNG and refuses a file at the 10 MB
     limit **before** reading it into memory.
   - Both return an `UploadFile` of bytes, never a `dart:io` `File`, so the
     same path works on the web demo, where a picked file has no path.
     `UploadFile` gains the file's `name`, for the document tile.
   - Null means the person cancelled.
   - `formatFileSize` gives the tile's "2.1 MB".
3. **Removed from the service as supplied:**
   - video and multi-file picking, which nothing needs;
   - a compression helper that rotated every image by 180° and crashed when
     compression failed; `flutter_image_compress` went with it, since
     `image_picker` resizes and re-encodes itself;
   - a size helper that ignored its `decimals` argument.
4. **iOS `Info.plist`** gains `NSCameraUsageDescription` and
   `NSPhotoLibraryUsageDescription`. Without them iOS terminates the app on
   the first pick, and App Review rejects the build.

## 2. Business justification

A practitioner cannot finish sign-up without a photo and a licence, and a
crash on the first tap would end the demo.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the screens that call it (brief 04); Kiswahili
versions of the iOS permission text (`InfoPlist.strings`), which follow the
screens.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Dependencies | **Affected** | `image_picker`, `file_picker` |
| iOS | Affected | Two usage strings; Swift packages resolved |
| Android | None | The system photo picker and document picker need no permission |
| Security (rules, App Check, RASP, secrets) | None | Limits mirror `storage.rules`, which still decides |

## 5. Risk & rollback plan

- **The device check mirrors `storage.rules` and does not replace it.** If
  the two drift, the rules still refuse, with a less helpful message.
- **HEIC from an iPhone gallery** is re-encoded to JPEG by `image_picker`
  when a quality is set, so the rules' `image/*` check holds.

**Rollback plan:** revert the commit.

## 6. Implementation plan

Read the supplied service; checked `file_picker` 13's API in the package
source (`pickFile`, `PlatformFile.readAsBytes`, `length`); rewrote the
service; added the iOS strings; confirmed with `make ios-deps` that no
`Podfile` is generated.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `test/core/services/file_picker_service_test.dart` | 8 passing: resize and bytes, cancel, refused access, oversize photo, licence types, licence refused before read, other types refused, sizes |
| `plutil -lint ios/Runner/Info.plist` | OK |
| `make ios-deps` | Swift packages resolved; no `Podfile` |
| `make gen`, `make fmt`, `make analyze`, `make bloc-lint`, `make test`, `make spell` | See the commit |
| Certification | 2026-10-28 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-28 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | New dependencies and permissions | Covered by CTO | 2026-10-28 | Approved — two widely used plugins; camera and photos only on request |

## 9. Post-implementation review

- On an iPhone and an Android phone, pick a camera photo, a gallery photo
  and a PDF; confirm the permission text and the upload.

## 10. Related records

- Previous CRQ: [CRQ-0030](./CRQ-0030-design-tokens-and-shared-widgets.md)
- Uploads and limits: [CRQ-0026](./CRQ-0026-specialties-and-license-files.md)
