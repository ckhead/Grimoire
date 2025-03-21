
# LaTeX tricks
## todo
```latex
\documentclass[12pt,final]{article}
\PassOptionsToPackage{obeyFinal}{todonotes}
\usepackage{todonotes}
\newcommand{\td}[1]{\todo[inline]{#1}}
```

## Algorithms, pseudo code, and just plain code
Documentation:  MyEducation/LaTeX/pseudo.pdf 

displaying code verbatim
```latex
\usepackage{listings}
\begin{document}
\begin{lstlisting}[language=R]
fib <- function(n) {
  if (n < 2)
    n
  else
    fib(n - 1) + fib(n - 2)
}
fib(10) # => 55
\end{lstlisting}
\end{document}
```

## if/else
```latex
\usepackage{ifthen}
\newif\ifpreview\previewfalse
\previewfalse
\begin{document}
\ifpreview
stuff
\fi
```

## Subfigure
```latex
\begin{figure}[htb]\centering
\caption{Arctic Sea Ice Extent}\label{fig:seaice}
\begin{subfigure}[b]{0.49\textwidth}\caption{1980}
\includegraphics[width=\textwidth]{Figures/Seaice_1980.jpg}
\end{subfigure}
\begin{subfigure}[b]{0.49\textwidth}\caption{2012}
\includegraphics[width=\textwidth]{Figures/Seaice_2012.jpg}
\end{subfigure}
\footnotesize Images: US National Aeronautics and Space Administration
\end{figure}
```

## Bibtex
[all the 14 BibTeX entry types](https://www.bibtex.com/e/entry-types/)
 including their description on when to use.

[Switch to biblatex?](https://tex.stackexchange.com/questions/5091/what-to-do-to-switch-to-biblatex)

getting first names instead of just initials: 
```latex
\bibliographystyle{aea}
```
see BLP_REStat

## VS Code: LaTeX Workshop
[VS code debugging](https://tex.stackexchange.com/questions/609841/latex-workshop-in-vscode-failed-to-compile)
The -shell-escape argument (which is needed for minted to do the pigmentation) seems to be missing when you compile the document.
Go to VSC settings (Ctrl/Cmd+,) and type latex-workshop.latex.tools. Click "Edit in settings.json". Then add "-shell-escape", in args like below:
"latex-workshop.latex.tools": 
```
[ { "name": "latexmk", "command": "latexmk", "args": [ "-shell-escape", // HERE "-synctex=1", "-interaction=nonstopmode", "-file-line-error", "-pdf", "-outdir=%OUTDIR%", "%DOC%" ], ...
```
Finally, save settings.json and recompile you .pdf.


Build on save vs build on file change settings
https://github.com/James-Yu/LaTeX-Workshop/wiki/FAQ#I-use-build-on-save-but-I-occasionally-want-to-save-without-building

## TiKZ
https://kochiuyu.github.io/tikz/tikz-cookbook/ (looks great)
https://tikz.net/skip-connection/
https://tikz.org/examples/chapter-02-creating-the-first-tikz-images/

## Converters
LaTeX2rtf ( http://latex2rtf.sourceforge.net/) is the easiest and fastest way to convert .tex files to .rtf that can be read by Microsoft Word. Using it is as simple as downloading the program, choosing your .tex file, and pressing run. A command window will open up to display the progress and warn of any errors. In most cases the default settings will be sufficient and despite errors it can usually output something useable.
some people also recommend opening the PDF in Word.


https://tableconvert.com/latex-to-excel  (have not tried it)


## Miscellaneous
https://nhigham.com/2019/11/19/better-latex-tables-with-booktabs/

### Verbatim
when you're feeling lazy and want to paste regression output straight from R into a Beamer frame (with option of setting font size and colour)
```latex
\usepackage{fancyvrb}
\begin{frame}[fragile]{Regression results}
   \begin{Verbatim}[fontsize=\small,formatcom=\color{blue}]
                     Estimate   Cluster s.e. t value Pr(>|t|)   
home_originTRUE       0.169624     0.041629   4.075 4.62e-05 ***
log(dist_origin)     -0.062061     0.014556  -4.264 2.01e-05 ***
lang_origin           0.035190     0.025469   1.382 0.167078   
home_hqTRUE           0.120366     0.035178   3.422 0.000623 ***
log(dist_hq)          0.026195     0.010118   2.589 0.009630 **
lang_hq               0.042448     0.018836   2.254 0.024231 * 
   \end{Verbatim}
   \end{frame}
```

### textboxes 
```latex
\begin{tcolorbox}[colframe=blue!50!black, colback=blue!10!white, coltitle=white, title=Single-stage UFLP formulation as a MILP, label=box:blue]
	stuff
    \end{tcolorbox}
Box~\ref{box:blue} shows the formulation of the single-stage UFLP as a MILP.
```
 see more in appendix in HMM_BEV.tex and
 MyEducation/LaTeX/tcolorbox.pdf for documentation of features.

```latex
\usepackage{tcolorbox}
\newtcolorbox[auto counter,number within=section]{mytextbox}[2][]{% 
colback=gray!5!white,colframe=gray!75!black,fonttitle=\bfseries, title=Box~\thetcbcounter: #2,#1}

\begin{mytextbox}[label={myautocounter}]{Title with number}
	This box is automatically numbered with \ref{myautocounter}.
\end{mytextbox}
Box \ref{myautocounter} shows...
```

### NOTA BENE:
- Errors with no error message occur if you try to includegraphics a corrupted pdf file.
