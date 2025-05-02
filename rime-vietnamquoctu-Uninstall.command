#!/bin/bash

# Kiểm tra và gỡ cài đặt Squirrel nếu có trong Brew
if command -v squirrel >/dev/null 2>&1; then
    echo "✅ Squirrel đã được cài đặt trong Brew. Đang tiến hành gỡ cài đặt..."
    brew uninstall --cask squirrel || {
        echo "❌ Gỡ cài đặt Squirrel thất bại!"
        exit 1
    }
    echo "✅ Đã gỡ cài đặt Squirrel!"
else
    echo "⚠️ Squirrel chưa được cài đặt trong Brew."
fi

# Danh sách thư mục/tệp cần xoá
FILES_TO_DELETE=(
    "/Library/Input Methods/Squirrel.app"
    "/Library/Receipts"
    "$HOME/Library/Rime"
)

# Xóa thư mục và tệp liên quan đến Squirrel
echo "🗑️ Đang xóa các tệp và thư mục liên quan đến Squirrel..."
for FILE in "${FILES_TO_DELETE[@]}"; do
    if [[ -e "$FILE" ]]; then
        sudo rm -rf "$FILE"
        echo "✅ Đã xóa: $FILE"
    else
        echo "⚠️ Không tìm thấy: $FILE"
    fi
done

# Xóa phương thức nhập Squirrel khỏi hệ thống
if defaults read | grep -q "im.rime.inputmethod.Squirrel"; then
    defaults delete im.rime.inputmethod.Squirrel
    echo "✅ Đã xóa phương thức nhập Squirrel trong cài đặt!"
else
    echo "⚠️ Không tìm thấy phương thức nhập Squirrel trong cài đặt!"
fi

# Nhắc nhở logout
echo "🚀 Đã gỡ cài đặt Squirrel hoàn tất!"
read -r -p "Bạn có muốn đăng xuất ngay bây giờ không? (y/n): " confirm

if [[ "$confirm" == "y" ]]; then
    echo "🔄 Đang đăng xuất..."	
    sudo pkill -KILL -u "$(whoami)"
else
    echo "⚠️ Bạn đã chọn không đăng xuất. Hãy đăng xuất thủ công nếu cần!"
fi
