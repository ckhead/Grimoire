#Shell Commands (including Git)
## Git

### token renewal:

1.  [[https://github.com/settings/tokens/2035322711/regenerate]{.underline}](https://github.com/settings/tokens/2035322711/regenerate),
    follow steps to generate a classic token, copy it because otherwise
    you lose it.

2.  paste from step 1the newly generated classic token instead of you
    password when you git push.

### commands to create a repository
```
cd Repos/Grimoire
git init
touch README.md
git add .
git commit -m "Initial commit with files"
```
Go to GitHub and create a new repository. Don’t initialize it with a README or any other files if you’re pushing an existing project.

```
git remote add origin https://github.com/ckhead/Grimoire.git
git push -u origin master
```
### updating commands once you have the repository set up
make sure you have the latest version on your local 
```
git pull
```
here are the basic commands to update from your local site:

```
git add .

git commit -m "revise draft of the paper"

git push
```
## Other Shell commands

### pandoc
```
brew install pandoc

pandoc -s myfile.docx -t markdown -o myfile.md
```

### sips

1.  convert HEIC to jpeg, resize
```
for file in *.HEIC; do sips -s format jpeg "$file" --out
"${file%.*}.jpeg"; done

for file in p*.HEIC; do sips -Z 1024 -s format jpeg "$file" --out
"${file%.*}.jpeg"; done
```
2.  crop from top and bottom of a png file
```
for file in C_Americas_*.png; do

sips -c 530 700 "$file" --out "$file"
```
done

### find/grep
```
find . -name "*.bib" -exec grep -il "Author_etal2015" {} +

grep -ril --include="*.bib" "Author_etal2015" .
```
the following gives way too much output
```
find . -exec grep -l "Author_etal2015" '{}' ;
```
note: lower case ell above, not the number one

> find .: This tells find to search the current directory (and
> subdirectories).
>
> • -exec: This option runs the command that follows for each file
> found.
>
> • grep "Author_etal2015": The command being executed by -exec, where
> we search for the string "Author_etal2015".
>
> • {}: This placeholder gets replaced with the name of each file found
> by find before executing grep on that file.
>
> • ;: This marks the end of the -exec command.

### cat
```
cat file1.bib file2.bib file3.bib > file_combined.bib
```
will replace file_combined.bib with the combined contents of all three
files.
```
cat file1.bib file2.bib file3.bib >> file_combined.bib
```
will add the contents of the three files to the **end** of
file_combined.bib without erasing its existing content.

## Executable scripts

Remove latex auxiliary files (email by Keith, 2023.10.2):

1. In the Terminal, create the Scripts folder in the root directory

```
cd ~/

mkdir -p Scripts
```
2. In your editor, create the following two .sh files (ls is the unix
list files in directory command, rm is remove file ), each with one
line.
```
aux_ls.sh

find -E . -type f -regex
'.*.(aux|log|nav|out|snm|toc|vrb|bbl|blg|fdb_latexmk|fls|synctex.gz)'

aux_rm.sh

find -E . -type f -regex
'.*.(aux|log|nav|out|snm|toc|vrb|bbl|blg|fdb_latexmk|fls|synctex.gz)'
-exec rm {} +
```
3. In the Terminal, make these files executable
```
cd ~/Scripts

chmod +x aux_ls.sh

chmod +x aux_rm.sh
```
4. in the terminal check if you already have a .bash_profile
```
cd ~/

ls -a
```
If not create this file
```
touch .bash_profile
```
5. Back in your editor, open the .bash_profile file in the root
directory and add the following
```
export PATH="$PATH:~/Scripts"
```
now type
```
source .bash_profile
```