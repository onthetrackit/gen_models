#!/bin/bash
fvm=$1
clear
# Xóa tất cả file .g.dart và mapper.dart trong thư mục lib và các thư mục con
echo "Đang xóa các file .g.dart và mapper.dart trong thư mục lib..."
find lib -type f \( -name "*.g.dart" -o -name "*mapper.dart" \) -delete

# Kiểm tra nếu có file nào bị xóa không
if [ $? -eq 0 ]; then
    echo "Đã xóa thành công các file generated."
else
    echo "Có lỗi khi xóa file."
    exit 1
fi

# Chạy build_runner
echo "Đang chạy build_runner..."
if [[ -z $fvm ]]; then
fvm dart run build_runner build --delete-conflicting-outputs
fi

echo "Hoàn tất!"