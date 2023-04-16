import os
import argparse
import openai
import json

# Load your API key from an environment variable or a configuration file
openai.api_key = "your_openai_api_key"

# replace with 

def process_chunk_with_chatgpt(chunk):
    response = openai.Completion.create(
        engine="chatgpt-2023",
        prompt=chunk,
        max_tokens=150,
        n=1,
        stop=None,
        temperature=0.5,
    )
    message = response.choices[0].text.strip()
    return message

def split_text(input_file, token_limit):
    script_location = os.path.dirname(os.path.abspath(__file__))
    output_folder = script_location
    output_prefix = "chunk"

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    words = []
    chunk_count = 1
    with open(input_file, "r") as f:
        for line in f:
            words.extend(line.split())
            while len(words) >= token_limit:
                chunk = " ".join(words[:token_limit])
                response = process_chunk_with_chatgpt(chunk)
                with open(os.path.join(output_folder, f"{output_prefix}_{chunk_count}.txt"), "w") as chunk_file:
                    chunk_file.write(response)
                words = words[token_limit:]
                chunk_count += 1

    if words:
        chunk = " ".join(words)
        response = process_chunk_with_chatgpt(chunk)
        with open(os.path.join(output_folder, f"{output_prefix}_{chunk_count}.txt"), "w") as chunk_file:
            chunk_file.write(response)

def main():
    parser = argparse.ArgumentParser(description="Split a text file into smaller chunks and process them with ChatGPT API")
    parser.add_argument("input_file", help="Path to the input text file")
    parser.add_argument("token_limit", type=int, help="Maximum number of tokens per chunk")

    args = parser.parse_args()
    split_text(args.input_file, args.token_limit)

if __name__ == "__main__":
    main()
