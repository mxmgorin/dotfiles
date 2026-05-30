source /usr/share/cachyos-fish-config/cachyos-config.fish
alias hx=helix

# Go environment
set -x PATH /usr/local/go/bin $PATH
set -x GOPATH $HOME/go
set -x PATH $GOPATH/bin $PATH

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
