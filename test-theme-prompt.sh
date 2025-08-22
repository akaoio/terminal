#!/bin/bash

echo "=== THEME PROMPT COLOR TEST ==="
echo ""
echo "Đây là script test để xem theme có thay đổi màu prompt không."
echo "Script sẽ chuyển qua từng theme và hiển thị prompt."
echo ""
echo "Nhấn Enter để bắt đầu..."
read

# Test each theme
for theme in dracula cyberpunk nord gruvbox; do
    echo ""
    echo "========================================="
    echo "Testing theme: $theme"
    echo "========================================="
    
    # Run zsh with theme change
    zsh -c "
        source ~/.zshrc
        theme set $theme > /dev/null 2>&1
        echo ''
        echo 'Theme đã được set thành: $theme'
        echo 'Bây giờ bạn sẽ thấy prompt với màu của theme $theme:'
        echo ''
        # Force p10k to show prompt
        print -P '%B%F{\$POWERLEVEL9K_CONTEXT_FOREGROUND}%n@%m%f %F{\$POWERLEVEL9K_DIR_FOREGROUND}%~%f %F{\$POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND}>%f%b'
    "
    
    echo ""
    echo "Nhấn Enter để test theme tiếp theo..."
    read
done

echo ""
echo "=== KẾT THÚC TEST ==="
echo ""
echo "Để apply theme vĩnh viễn, chạy trong terminal của bạn:"
echo "  theme set <tên_theme>"
echo ""
echo "Sau đó chạy: exec zsh"
echo "để restart shell với theme mới."