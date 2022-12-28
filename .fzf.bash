# Setup fzf
# ---------
if [[ ! "$PATH" == */home/moises/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/moises/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/moises/.fzfCompletion.bash" 2> /dev/null

# Key bindings
# ------------
source "/c/Users/tohias/.fzfKeyBindings.bash"
