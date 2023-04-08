import os

def split_text(input_file, output_folder, output_prefix, chunk_size):
    with open(input_file, "r") as f:
        text = f.read()
    
    num_chunks = len(text) // chunk_size + (1 if len(text) % chunk_size > 0 else 0)
    
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    for i in range(num_chunks):
        start = i * chunk_size
        end = (i + 1) * chunk_size
        chunk = text[start:end]
        with open(os.path.join(output_folder, f"{output_prefix}_{i + 1}.txt"), "w") as f:
            f.write(chunk)

# Usage:
input_file = "/Users/rafi/Projects/devops-toolkit/misc/pr_to_review.txt"
output_folder = "chunks"
output_prefix = "chunk"
chunk_size = 1200
split_text(input_file, output_folder, output_prefix, chunk_size)
