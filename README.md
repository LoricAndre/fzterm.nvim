# FZTerm

## Idea
FZTerm is my attempt at a fuzzy finder plugin, using a floating terminal and basically nothing else.
The basic idea is to make it fully customizable, the plugins provides the basic framework and a few implementations.
The only dependencies are fzf and ag, but the framework is stil usable without them.

## Usage
The `:Files`, `:GFiles`, `:Buffers`, `:Branches` and `:Ag` commands are implemented, and the rest is up to your needs and creativity

## Extensions
 - The plugins provides the `fzterm` function, accessible via `lua require'fzterm'.fzterm()'
 - The function takes 4 arguments, the first 3 are shell commands :
  - `pre_cmd`, the command that will be piped into fzf or any fuzzy finder you choose (see 'matcher' arg)
  - `post_cmd`, the command the result is piped into, if empty or `false` the result is simply opened in a new buffer
  - `matcher`, what pre_cmd is piped into, usually fzf with args (default is `fzf --preview 'bat --color=always {}'`)
  - `internal` changes the way `pre_cmd` is ran : if `true`, pre_cmd can be a vim command and will be executed in the current buffer

