# My Setup

This repo contains the setup scripts that I use to set up new machines with my dev environment.  
I have a couple of main choices in my setup that I really like to use.

## Window Management

### i3
##### Tiling Window Manager
[i3](https://i3wm.org/) is a tiling windows manager for linux which is super simple, but allows for speed of organizing windows on your screen simply and without a mouse.  By default windows are pretty flat, but i3 has a tree based structure of window display which allows for extreme configurability in what you can do.  

### i3-status-rust
##### A nice Toolbar for i3
[i3-status-rust](https://github.com/greshake/i3status-rust) is a really nice community built status bar for the i3 windows manager.  It looks quite nice and also has computer utilization configurable pieces, which I use heavily.  I find that having a passive computer monitor is extremely helpful because when things slow down you can immediately tell why your computer is acting up or has extra latency. 

### dunst
##### Custom notifications following the same theme

## Applications

### Spacemacs
##### VIM+Emacs
[Spacemacs](https://github.com/syl20bnr/spacemacs) is a combination of Vim and Emacs, initially designed for Vim users with the Emacs ecosystem.  It's highly configurable and navigatable without a mouse.  
Features I love the most:
- No need for using a mouse ever
- Vim style editing (quick mouse key bindings)
- Configurability - layer support for different langauges, tools, etc
- Runnable in a shell (no gui needed)
- (SPC SPC) lookup all possible calls

### Alacritty/kitty
##### GPU accelerated terminal shells
**Why use GPU accelerated shells?**
I found that GPU accelerated shells have much smoother scrolling versus cpu enabled ones.  When scrolling through thousands of generated lines, I find that the experience scrolling on Alacritty or Kitty has been the smoothest


## Tools

### AG (silver searcher)
AG is just a better seasrching tool for codebases.  

### RG (rip grep)

### tree



### Config Dotfiles

#### Vimrc
I use vim if I really want 
