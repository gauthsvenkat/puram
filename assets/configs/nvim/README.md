# Personal neovim config

Make sure you have [neovim](https://neovim.io/) installed. You can then run

```bash
git clone https://github.com/gauthsvenkat/nvim.git ~/.config/nvim/
```

Before you start `nvim`, make sure you have the following external tools installed and available in your `$PATH`.

## Requirements

Following table lists the required (external) tools and which plugins require them.

Legend; `x` - required, `o` - optional, `-` - not used

| Tool             | blink.cmp | fzf-lua | grug-far.nvim | lazy.nvim | mason.nvim | nvim-treesitter | snacks.nvim |
|------------------|:---------:|:-------:|:-------------:|:---------:|:----------:|:---------------:|:-----------:|
| **bat**          |     -     |    o    |     -         |     -     |     -      |        -        |      -      |
| **bash**         |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
| **cargo**        |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
| **cc (gcc)**     |     -     |    -    |     -         |     -     |     -      |        x        |      -      |
| **curl**         |     x     |    -    |     -         |     -     |     x      |        -        |      -      |
| **fd**           |     -     |    x    |     -         |     -     |     -      |        -        |      x      |
| **fzf**          |     -     |    x    |     -         |     -     |     -      |        -        |      -      |
| **git**          |     x     |    x    |     -         |     x     |     -      |        x        |      x      |
| **gzip**         |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
| **node**         |     -     |    -    |     -         |     -     |     x      |        x        |      -      |
| **npm**          |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
| **python3**      |     -     |    -    |     -         |     x     |     x      |        -        |      -      |
| **python3 venv** |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
| **ripgrep (rg)** |     -     |    x    |     x         |     -     |     -      |        -        |      x      |
| **tar**          |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
| **unzip**        |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
| **wget**         |     -     |    -    |     -         |     -     |     x      |        -        |      -      |
