# Grimoire
A grimoire is "a book of magic spells and invocations."

I have a bunch of Google Docs where I put code that I use infrequently and tend to forget. 
So now my plan is to convert these files to Markdown and gradually move them up to Grimoire.
- [Shell commands including git](https://github.com/ckhead/Grimoire/blob/main/shell_commands.md)
- [LaTeX packages and tricks](https://github.com/ckhead/Grimoire/blob/main/LaTeX_tricks.md)
- R (mainly data.table)
- Julia
  
So far I have done this for Shell and LaTeX.

Does this README render latex? $y =\beta x +\epsilon$

$$y_i = x_i^\beta$$

The two key things GitHub needs for display-mode LaTeX:

1. A blank line before $$ — without it, GitHub treats it as regular text in the preceding paragraph.

2. No spaces between $$ and the expression (i.e., $$y_i...$$ not $$ y_i... $$) Push that change and it should render properly.
