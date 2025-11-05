#!/bin/bash

# Thư mục bắt đầu (mặc định là thư mục hiện tại nếu không truyền đối số)
START_DIR="lib"

echo "🧹 Đang xóa các file *.g.dart và *mapper.g.dart trong: $START_DIR"

# Tìm và xóa các file .g.dart và mapper.g.dart
find "$START_DIR" -type f \( -name "*.g.dart" -o -name "*mapper.g.dart" \) -print -delete

echo "✅ Hoàn tất."
echo "build mapper"
clear && fvm dart run build_runner build --delete-conflicting-output

