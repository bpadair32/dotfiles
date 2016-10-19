############
#
#Script to symlink dotfiles
#
#

mkdir ~/dotfiles_old

for file in bash_profile gitconfig gitignore_global ssh vim vimrc
do
  mv ~/.$file ~/dotfiles_old/
  ln -s ~/Documents/dotfiles/$file ~/.$file
done
