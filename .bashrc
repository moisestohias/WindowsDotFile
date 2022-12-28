export EDITOR='nvim'
export VISUAL='subl' # crontab doesn't work with ST for what fucking reason.

case $- in # If not running interactively, don't do anything. Don't know what this does yet.
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
#shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# set title of current terminal 
function ttl() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}


# Add my script6s
if [ -d "$HOME/.scripts" ] ; then
    PATH="$HOME/.scripts:$PATH"
fi

function fzim(){ 
    files=$(fzf --preview="bat.exe -nf {}") && nvim "$files" 
}

open_with_fzf() {
    #start "" "$( fd -t f -H -I | fzf)"
    files=$(fzf) && start "" "$files" 
}

cd_with_fzf() {
    cd $HOME && cd "$(find -type d | fzf --preview="tree -L 1 {}" --bind="space:toggle-preview" --preview-window=:hidden)"
}

magic() { rg . | fzf | cut -d ":" -f 1 | awk '{print "\x27" $0 "\x27" }' | xargs -r nvim;}


fzfmagic() { 
    what="$(grep -r . | fzf --delimiter : --preview="less {1}" | cut -d ":" -f 1)"
    nvim "$what"
}

fapt(){
    apt-cache search '' | cut -d ' ' --fields 1 | fzf --multi --cycle --reverse --preview 'apt-cache show {1}'
}

function emoji() {
    # make sure you have .emoji.txt in your home,
    if [ -f ~/.emojis.txt ]; then
        powershell.exe -c "set-clipboard -value " "$(cat ~/.emojis.txt | fzf | cut -d " " -f 1)"
    else
        curl -sSL 'https://git.io/JXXO7' > .emojis.txt  
        powershell.exe -c "set-clipboard -value " "$(cat ~/.emojis.txt | fzf | cut -d " " -f 1)"
    fi

}
export CurrentWindowWidth=$(wmic path Win32_VideoController get CurrentHorizontalResolution|  sed '2q;d')
export CurrentWindowHight=$(wmic path Win32_VideoController get CurrentVerticalResolution|  sed '2q;d')
export CurrentWindowWidthM20=$(($CurrentWindowWidth - 20 ))
export CurrentWindowHightM20=$(($CurrentWindowHight - 20 ))

# Built in screen size 1920x1024, external 1600x900
alias scast="ffmpeg -v error -f alsa -ac 1 -i default -f x11grab -r 30 -s 1600x900 -i :0.0 -acodec pcm_s16le -vcodec libx264 -preset ultrafast -crf 0 "
# alias screencastPluse="ffmpeg -f pulse -i 3 -ac 2 -f x11grab -r 30 -s 1600x900 -i :0.0 -acodec pcm_s16le -vcodec libx264 -preset ultrafast -crf 0 -y screencast.mkv"
alias screencast-no-sound="ffmpeg -y -f x11grab -r 30 -s 1600x900 -i :0.0 -vcodec libx264 -preset ultrafast -crf 0 "
alias webcast-external="ffmpeg -f alsa -ac 2 -i hw:1,0 -f v4l2 -itsoffset 1 -s 640x480 -i /dev/video0 -acodec pcm_s16le -vcodec libx264 -y output.mkv"
alias webcast-internal="ffmpeg -f alsa -ac 2 -i hw:0,0 -f v4l2 -itsoffset 1 -s 640x480 -i /dev/video0 -acodec pcm_s16le -vcodec libx264 -y output.mkv"
twitch() {
   INRES="1600x900" # input resolution
   OUTRES="1280x720" # output resolution
   FPS="30" # target FPS
   # GOP="$(( $FPS * 2 ))" # i-frame interval, should be double of FPS
   GOP="60" # i-frame interval, should be double of FPS
   GOPMIN="$FPS" # min i-frame interval, should be equal to fps
   THREADS="4" # max 6
   CBR="1000k" # constant bitrate (should be between 1000k - 3000k)
   QUALITY="ultrafast"  # one of the many FFMPEG preset
   AUDIO_RATE="44100"
   STREAM_KEY="$(pass show web/twitch/key)"
   SERVER="live-dfw" # twitch server in frankfurt, see http://bashtech.net/twitch/ingest.php for list
   PROBESIZE="42M"

   ffmpeg \
      -f x11grab -s "$INRES" -r "$FPS" -probesize $PROBESIZE -i :0.0 \
      -f pulse -i 3 -f flv -ac 2 -ar $AUDIO_RATE \
      -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p\
      -s $OUTRES -preset $QUALITY -acodec libmp3lame -threads $THREADS -strict normal \
      -bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
}
youtube-stream() {
   INRES="1600x900" # input resolution
   OUTRES="1280x720" # output resolution
   FPS="30" # target FPS
   GOP="$(( $FPS * 2 ))" # i-frame interval, should be double of FPS
   GOPMIN="$FPS" # min i-frame interval, should be equal to fps
   THREADS="4" # max 6
   CBR="1000k" # constant bitrate (should be between 1000k - 3000k)
   QUALITY="ultrafast"  # one of the many FFMPEG preset
   AUDIO_RATE="44100"
   STREAM_KEY="$(pass show web/youtube/key)"
   PROBESIZE="42M"

   ffmpeg \
      -f x11grab -s "$INRES" -r "$FPS" -probesize $PROBESIZE -i :0.0 \
      -f pulse -i 3 -f flv -ac 2 -ar $AUDIO_RATE \
      -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p\
      -s $OUTRES -preset $QUALITY -acodec libmp3lame -threads $THREADS -strict normal \
      -bufsize $CBR "rtmp://a.rtmp.youtube.com/live2/$STREAM_KEY"
}
media() {
    find . -type f | awk '{print "\x27" $0 "\x27" }'|sort| xargs -n1 mpv -
}

cleanSub() {
    cat "$0" | grep -Pv '^\d+' | grep -v '^\s*$' | uniq -ui > "$2.txt"
}


SubToText() {
    yt-dlp $0 --sub-lang en --write-sub --sub-format vtt --convert-subtitles srt --write-auto-sub --skip-download
    ls -ct | head -1 | awk '{print "\x27" $0 "\x27"}' | xargs grep -Pv '^\d+|^\s*$' | uniq -iu > clean.txt
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

function playMedia() {
    find $(pwd) -type f | egrep '\.(webm|mkv|mp4|m4a|aac|mp3|wav)$' | awk '{print "\x22" $0 "\x22" }' | sort | xargs -n 1 ffplay -autoexit -v error -x $CurrentWindowWidthM20 -y $CurrentWindowHightM20 -noborder -i 
}

### Abbreviations  ======================================================
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias v='nvim.exe'
alias vim='nvim.exe'
alias nvim='nvim.exe'
alias df='df -h'
alias free='free -g'
alias reboot='sudo reboot'
alias virtnetwork='sudo virsh net-start default'
alias p='ping -aAc 4 192.168.1.1 && ping -aAc 4 google.com '
alias h='cd ~/'
alias n='cd D:/Notes'
alias m='cd D:/Music'
alias d='cd ~/Downloads'
alias doc='cd D:/Documents'
alias w='cd D:/Pictures/Walls'
alias c='clear'
alias r='ranger .'
alias rm='rm -rf'
alias ..='cd ..'
alias ...='cd ../..'
alias ld='fd -t d -d 1'
alias lf='fd -t f -d 1'
alias l='exa --icons --group-directories-first'
alias ll='exa --icons --group-directories-first -l'
alias la='exa --icons --group-directories-first -a'
alias lh="ls -ld .*" # "ls -A | egrep '^\.'" This works but not as an alias
alias lhf="ls -ld .* | grep -v ^d" # https://linuxhandbook.com/display-only-hidden-files/
alias lhf="ls -ld .* | grep -v ^d"
alias merge='xrdb -merge ~/.Xresources'
alias q='exit'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias .s='cd ~/.scripts'
alias pk='sudo pkill'
# alias pk='ps -ef | fzf  | awk '{print $2}' | xargs kill -9'
alias search='w3m google.com'
alias what='dictl -d fd-eng-ara (cat /usr/share/dict/words | fzf --reverse) | tail -n 2'
alias def='dictl  (cat /usr/share/dict/words | fzf --reverse)'
alias pallet='pastel random | pastel mix $(pastel random -n 1) | pastel lighten 0.2 | pastel format | pastel format'
alias printPallet='pastel color $(cat pallet.txt | tr "#" " " ) | pastel format'
alias arec='arecord -r 44100 -f S16_LE '
alias fmrec='ffmpeg -v error -f alsa -i hw:0 '
alias ssc="ffmpeg -f x11grab -video_size 1920x1080 -framerate 30  -i :0.0+0,0 -strict experimental  -v error"
alias fplay='ffplay -v error -x $CurrentWindowWidthM20 -y $CurrentWindowHightM20 -noborder'
alias nplay='ffplay -vf negate -v error -x $CurrentWindowWidthM20 -y $CurrentWindowHightM20 -noborder'
alias oplay='ffplay -v error -nodisp'
alias yto='yt-dlp -f 251 '


# Binding
bind '"\C-c":"cd_with_fzf\n"'
bind '"\C-o":"open_with_fzf\n"'
bind '"\C-v":"vim\n"'
