TMP_DIR=$(mktemp -d)
# INSTALL alacritty
if [ -d "/Applications/Alacritty.app" ]; then
  echo "✅ alacritty already installed"
else
  echo "installing alacritty"
  git clone git@github.com:alacritty/alacritty.git $TMP_DIR/alacritty
  cd $TMP_DIR/alacritty
  make app
  cp -r target/release/osx/Alacritty.app /Applications/
  ln -s /Applications/Alacritty.app/Contents/MacOS/alacritty /usr/local/bin/alacritty
  sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
  mkdir -p ~/.zsh_functions
  cp extra/completions/_alacritty ~/.zsh_functions/_alacritty
  echo "✅ alacritty succesfully \installed"
fi
