#!/bin/bash

# Kiểm tra xem Homebrew đã được cài đặt chưa, nếu chưa thì cài đặt

read -sp "Nhập mật khẩu cài đặt: " PASSWORD
if [[ "$PASSWORD" != "VN1975" ]]; then
    echo "❌ Mật khẩu sai!"
    exit 1
fi
echo "✅ Mật khẩu đúng, tiếp tục thực thi..."
if ! command -v brew >/dev/null 2>&1; then
    echo "⚠️ Homebrew chưa được cài đặt. Đang tiến hành cài đặt..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "❌ Cài đặt Homebrew thất bại!"
        exit 1
    }
    echo "✅ Homebrew đã được cài đặt thành công!"
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
else
    echo "✅ Homebrew đã được cài đặt!"
fi

# Kiểm tra xem Squirrel đã được cài đặt chưa, nếu chưa thì cài đặt
SQUIRREL_PATH="/Library/Input Methods/Squirrel.app"

if [[ ! -d "$SQUIRREL_PATH" ]]; then
    echo "⚠️ Squirrel chưa được cài đặt. Đang tiến hành cài đặt..."
    # Kiểm tra phiên bản macOS
    MACOS_VERSION=$(sw_vers -productVersion | cut -d '.' -f 1,2)
    echo "🖥️ Phiên bản macOS hiện tại: $MACOS_VERSION"

    # So sánh phiên bản macOS
    REQUIRED_VERSION="13.0"

    if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$MACOS_VERSION" | sort -V | head -n1)" == "$REQUIRED_VERSION" ]]; then

        echo "✅ macOS $MACOS_VERSION đủ điều kiện cài đặt Squirrel bản mới nhất."
        brew install --cask squirrel || {
            echo "❌ Cài đặt Squirrel thất bại!"
            exit 1
        }
        echo "✅ Squirrel đã được cài đặt thành công!"
    else
        echo "❌ macOS $MACOS_VERSION không đủ điều kiện để cài đặt bản mới nhất Squirrel. Yêu cầu từ $REQUIRED_VERSION trở lên."

        # Tạo thư mục tạm để chứa file tải về
        TEMP="$HOME/Downloads/squirrel_temp"
        mkdir -p "$TEMP"
        cd "$TEMP"

        # Tải file zip
        ZIP_URL="https://github.com/rime/squirrel/releases/download/0.16.2/Squirrel-0.16.2.zip"
        echo "⬇️ Đang tải Squirrel từ $ZIP_URL..."
        curl -L -o Squirrel.zip "$ZIP_URL"

        # Kiểm tra nếu tải thành công
        if [[ -f "Squirrel.zip" ]]; then
            echo "✅ Tải thành công!"
        else
            echo "❌ Tải thất bại!"
            exit 1
        fi

        # Giải nén file zip
        echo "📦 Đang giải nén..."
        unzip -o Squirrel.zip

        # Tìm file .pkg
        PKG_FILE=$(find . -name "*.pkg" | head -n 1)

        if [[ -f "$PKG_FILE" ]]; then

            while true; do
                echo "🚀 Đang cài đặt $PKG_FILE..."
                sudo installer -pkg "$PKG_FILE" -target /
                INSTALL_STATUS=$?
                # Thực hiện hành động
                if [[ $INSTALL_STATUS -eq 0 ]]; then
                    echo "✅ Cài đặt Squirrel 0.16.2 thành công!"
                    break  # Thoát khỏi vòng lặp nếu thành công
                else
                    echo "❌ Cài đặt thất bại với mã lỗi $INSTALL_STATUS!"
                    read -p "👉 Bạn có muốn thử cài đặt lại Squirrel 0.16.2 không? (y/n): " retry
                    if [[ "$retry" != "y" ]]; then

                        break  # Thoát khỏi vòng lặp
                    fi
                    echo "🧹 Đang xóa các thư mục cũ..."
                    sudo rm -rf "/Library/Input Methods/Squirrel.app"
                    rm -rf ~/Library/Rime
                    echo "✅ Đã xóa xong. Đang thử cài đặt lại..."
                fi
            done

            echo "✅ Cài đặt hoàn tất!"
        else
            echo "❌ Không tìm thấy file .pkg!"
        fi
        
    fi
else
    echo "echo "📂 Squirrel đã được cài tại: $SQUIRREL_PATH""
fi
if [[ -n "$TEMP" && -d "$TEMP" ]]; then
    echo "🧹 Clean Cache ..."
    sudo rm -rf "$TEMP"
    echo "✅ Clean done"
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