# chatgpt_api_wrapper.py
import argparse
import json
import requests

class ChatGPTWrapper:
    def __init__(self, api_key):
        self.api_key = api_key
        self.api_url = "https://api.openai.com/v1/engines/davinci-codex/completions"

    def _make_api_call(self, messages, temperature=0.7, max_tokens=100):
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }

        data = {
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens
        }

        response = requests.post(self.api_url, headers=headers, json=data)
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]

    def ask(self, question):
        context = [
            {
                "role": "system",
                "content": "You are an AI model trained to provide useful information and answers."
            },
            {
                "role": "user",
                "content": "Tell me about the Foundry library and its features."
            },
            {
                "role": "assistant",
                "content": "Foundry is a relatively new library for Solidity smart contract development. It is designed to streamline the development process by providing a set of tools and utilities for creating, testing, and deploying smart contracts on the Ethereum blockchain. Key features of Foundry include a user-friendly interface, seamless integration with popular development environments, advanced debugging capabilities, and support for custom Solidity versions. While I am not directly familiar with the library, I can help answer general questions about Solidity and smart contract development based on these features."
            }
        ]

        user_question = {
            "role": "user",
            "content": question
        }
        context.append(user_question)

        response = self._make_api_call(context)
        return response

def main():
    parser = argparse.ArgumentParser(description="ChatGPT API Wrapper with Context")
    parser.add_argument("question", help="Enter your question for ChatGPT")
    args = parser.parse_args()

    api_key = "your_api_key_here"
    wrapper = ChatGPTWrapper(api_key)
    response = wrapper.ask(args.question)
    print(response)

if __name__ == "__main__":
    main()
