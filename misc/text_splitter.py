import os

def split_text(input_file, output_folder, output_prefix, token_limit):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    words = []
    chunk_count = 1
    with open(input_file, "r") as f:
        for line in f:
            words.extend(line.split())
            while len(words) >= token_limit:
                chunk = " ".join(words[:token_limit])
                with open(os.path.join(output_folder, f"{output_prefix}_{chunk_count}.txt"), "w") as chunk_file:
                    chunk_file.write(chunk)
                words = words[token_limit:]
                chunk_count += 1
        if words:
            chunk = " ".join(words)
            with open(os.path.join(output_folder, f"{output_prefix}_{chunk_count}.txt"), "w") as chunk_file:
                chunk_file.write(chunk)

# Usage:
input_file = "/Users/rafi/Projects/devops-toolkit/misc/text.txt"
output_folder = "/Users/rafi/Projects/devops-toolkit/misc/chunks"
output_prefix = "chunk"
token_limit = 300
split_text(input_file, output_folder, output_prefix, token_limit)
