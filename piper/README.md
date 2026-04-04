# Local Piper Setup

Keep Piper runtime files in this folder for local development.

Expected structure:

- piper/bin/piper/piper.exe
- piper/models/en_US-lessac-medium.onnx
- piper/models/en_US-lessac-medium.onnx.json
- piper/models/sw_CD-lanfrica-medium.onnx
- piper/models/sw_CD-lanfrica-medium.onnx.json

Notes:

- This repository ignores local Piper binaries/models by default.
- Only this README is tracked in git.
- Backend env paths are configured to point to this folder in backend/.env.
