# T1091 – Removable Media | Assessment

## MCQ 1
Windows disabled autorun.inf execution (from USB) after which version?
A) Windows XP  B) Windows Vista  C) Windows 7 (with MS10-046 patch fully blocking it)  ✅  D) Windows 10

## MCQ 2
Stuxnet used T1091 to jump an air-gapped network because:
A) The network used wireless  B) USB drives are carried between connected and air-gapped systems, bridging the physical isolation  ✅
C) Stuxnet only affected Windows XP  D) Air-gapped systems have no security

## MCQ 3
A modern alternative to autorun.inf for USB-based code execution is:
A) Embedding code in the USB firmware (BadUSB)  B) Using LNK shortcuts styled as folder icons that execute when double-clicked  ✅
C) PDF files with embedded payloads  D) Both A and B  ✅ (both valid but B is simpler)

## Fill 1
`autorun.inf` section header and key that specifies the executable to launch:
**Answer:** `[AutoRun]` / `open=<filename>`

## Fill 2
BadUSB attack category where the USB device presents itself as:
**Answer:** A keyboard (HID device) or network adapter
