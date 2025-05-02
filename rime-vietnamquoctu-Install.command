#!/bin/bash

# Kiểm tra xem Homebrew đã được cài đặt chưa, nếu chưa thì cài đặt
if ! command -v brew >/dev/null 2>&1; then
    echo "⚠️ Homebrew chưa được cài đặt. Đang tiến hành cài đặt..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "❌ Cài đặt Homebrew thất bại!"
        exit 1
    }
    echo "✅ Homebrew đã được cài đặt thành công!"
else
    echo "✅ Homebrew đã được cài đặt!"
fi

brew --version

# Kiểm tra shell hiện tại và thêm Homebrew vào profile nếu dùng Zsh
SHELL_PROFILE="$HOME/.zshrc"
if [[ "$SHELL" == */zsh ]]; then
    echo "⚙️ Đang thêm Homebrew vào Zsh profile..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$SHELL_PROFILE"
    source "$SHELL_PROFILE"
    echo "✅ Homebrew đã được thêm vào zsh!"
else
    echo "⚠️ Bạn không sử dụng zsh, nếu cần hãy thêm Homebrew vào shell của bạn thủ công."
fi

# Kiểm tra xem Squirrel đã được cài đặt chưa, nếu chưa thì cài đặt
SQUIRREL_PATH="/Library/Input Methods/Squirrel.app"
if [[ ! -d "$SQUIRREL_PATH" ]]; then
    echo "⚠️ Squirrel chưa được cài đặt. Đang tiến hành cài đặt..."
    brew install --cask squirrel || {
        echo "❌ Cài đặt Squirrel thất bại!"
        exit 1
    }
    echo "✅ Squirrel đã được cài đặt thành công!"
else
    echo "✅ Squirrel đã được cài đặt!"
fi

# Clone rime-vietnamquoctu và thay thế SharedSupport
echo "🔄 Đang cập nhật rime-vietnamquoctu..."
sudo git -C "$SQUIRREL_PATH/Contents/" clone https://github.com/nguyentutiensinh/rime-vietnamquoctu.git
sudo rm -rf "$SQUIRREL_PATH/Contents/SharedSupport"
sudo mv "$SQUIRREL_PATH/Contents/rime-vietnamquoctu/SharedSupport" "$SQUIRREL_PATH/Contents/"
sudo rm -rf "$SQUIRREL_PATH/Contents/rime-vietnamquoctu"

echo "✅ Cài đặt Rime Việt Nam Quốc Tự hoàn tất!"

# Nhắc nhở logout
read -p "Cài đặt đã xong. Bạn có muốn đăng xuất ngay bây giờ không? (y/n): " confirm

if [[ $confirm == "y" ]]; then
    echo "Đang đăng xuất..."
    sudo pkill -KILL -u "$(whoami)"
else
    echo "Bạn đã chọn không đăng xuất. Hãy đăng xuất thủ công nếu cần!"
fi