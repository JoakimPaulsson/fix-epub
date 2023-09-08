#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 directory"
  exit 1
fi

# Convert relative path to absolute path
dir_path=$(realpath "$1")

# Check if the argument is a directory
if [ ! -d "$dir_path" ]; then
  echo "Error: $dir_path is not a directory"
  exit 1
fi

# Loop through each .epub file in the specified directory
for epub_file in "$dir_path"/*.epub; do
  if [ -f "$epub_file" ]; then
    # Create a temporary directory and unzip the epub file there
    temp_dir=$(mktemp -d)
    unzip -q "$epub_file" -d "$temp_dir"
    
    epub_dir="$temp_dir/EPUB"

    # Modify the style.css file
    style_file="$epub_dir/style.css"
    if [ -f "$style_file" ]; then
      sed -i 's/p + br {/br {/' "$style_file"
      echo -e "\np {\n  margin: 0px;\n}\n\nbody {\n  text-indent: 0.5in;\n}" >> "$style_file"
      echo "Modified: $style_file"
    else
      echo "File not found: $style_file"
    fi

    # Zip the files back into .epub format and remove the temporary directory
    cd "$temp_dir" || exit
    new_epub_filename=$(echo "${epub_file##*/}" | sed 's/ /-/g' | sed 's/.epub/_modified.epub/')
    zip -q -r "$new_epub_filename" *
    mv "$new_epub_filename" "$dir_path"
    cd - > /dev/null || exit
    rm -r "$temp_dir"
  else
    echo "File not found: $epub_file"
  fi
done

