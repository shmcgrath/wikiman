#!/usr/bin/env bash

# [wikiman](https://github.com/filiparag/wikiman) setup script
# uses doas instead of sudo

install_doc_sources() {
	${EDITOR:-${VISUAL:-vi}} $XDG_CONFIG_HOME/wikiman/wikiman-makefile
	read -p "Use wikiman-makefile to install additional documentation sources? [y/n] " docChoice
		case "$docChoice" in
			[yY]* ) echo "installing additional documentation sources..."
				echo "installing gentoo docs..."
				make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile source-gentoo
				doas make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile source-install
				doas make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile clean
				echo "installing fbsd docs..."
				make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile source-fbsd
				doas make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile source-install
				doas make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile clean
				echo "installing tldr docs..."
				make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile source-tldr
				doas make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile source-install
				doas make --makefile $XDG_CONFIG_HOME/wikiman/wikiman-makefile clean
				;;
			[nN]* ) echo "not installing additional documentation sources";;
			* ) echo "Invalid selection; please answer yes (y) or no (n).";;
		esac
}

if [ -d "$XDG_CONFIG_HOME/wikiman" ]; then
	echo "$XDG_CONFIG_HOME/wikiman exists"
else
	echo "$XDG_CONFIG_HOME/wikiman does not exist"
	read -p "would you like to create $XGD_CONFIG_HOME/wikiman? [y/n] " dirChoice
		case "$dirChoice" in
			[yY]* ) mkdir --parents $XDG_CONFIG_HOME/wikiman;;
			[nN]* ) ;;
			* ) echo "Invalid selection; please answer yes (y) or no (n).";;
		esac
fi

echo "checking for wikiman config..."
if [ -f "$XDG_CONFIG_HOME/wikiman/wikiman.conf" ]; then
	echo "you have an existing wikiman config, diff existing config and system config"
	diff --report-identical-files /etc/wikiman.conf $XDG_CONFIG_HOME/wikiman/wikiman.conf
else
	echo "wikiman.conf does not exist"
	read -p "would you like to copy the default wikiman config to $XGD_CONFIG_HOME/wikiman/wikiman.conf? [y/n] " configChoice
		case "$configChoice" in
			[yY]* ) mkdir --parents $XDG_CONFIG_HOME/wikiman
				cat /etc/wikiman.conf >> $XDG_CONFIG_HOME/wikiman/wikiman.conf;;
			[nN]* ) ;;
			* ) echo "Invalid selection; please answer yes (y) or no (n).";;
		esac
fi

echo "install arch-wiki-docs via pacman..."
doas pacman -S arch-wiki-docs

echo "checking for wikiman-makefile"
if [ -f "$XDG_CONFIG_HOME/wikiman/wikiman-makefile" ]; then
	echo "wikiman-makefile exists"
	install_doc_sources
else
read -p "Would you like to download the latest wikiman Makefile from github? [y/n] " makefileChoice
	case "$makefileChoice" in
		[yY]* )
			mkdir --parents $XDG_CONFIG_HOME/wikiman
			curl --location 'https://raw.githubusercontent.com/filiparag/wikiman/master/Makefile' \
				--output $XDG_CONFIG_HOME/wikiman/wikiman-makefile
			install_doc_sources;;
		[nN]* ) echo "the makefile must be downloaded before installing additional sources..."
				echo "see https://github.com/filiparag/wikiman?tab=readme-ov-file#additional-documentation-sources";;
		* ) echo "Invalid selection; please answer yes (y) or no (n).";;
	esac
fi

echo "if it is not installed, fzf may want to be installed."
doas pacman -S fzf

echo "Wikiman can be launced using a shell key binding (default Ctrl+F)."
echo "Current command line buffer will be used as a search query."
echo "Add 'source /usr/share/wikiman/widgets/widget.bash' to your .bashrc
	if you would like to make the key binding permanent."
if [ -f "$XDG_CONFIG_HOME/wikiman/widget.bash" ]; then
	echo "you have a custom copy of the wikiman widget"
	vimdiff /usr/share/wikiman/widgets/widget.bash $XDG_CONFIG_HOME/wikiman/widget.bash
else
	echo "the default keybind can be changed with a custom copy of the widget"
	read -p "would you like to make a custom copy of the bash widget? [y/n] " widgetChoice
		case "$widgetChoice" in
			[yY]* ) mkdir --parents $XDG_CONFIG_HOME/wikiman
				cat /usr/share/wikiman/widgets/widget.bash >> $XDG_CONFIG_HOME/wikiman/widget.bash
				echo "don't forget to source this in .bashrc!";;
			[nN]* ) ;;
			* ) echo "Invalid selection; please answer yes (y) or no (n).";;
		esac
fi
