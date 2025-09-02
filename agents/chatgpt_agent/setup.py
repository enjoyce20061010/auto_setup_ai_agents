import os

def main():
    print("--- ChatGPT Agent Setup ---")
    api_key = input("Please enter your OpenAI API Key: ")
    if api_key:
        with open(".env", "w") as f:
            f.write(f"OPENAI_API_KEY={api_key}\n")
        print("✅ OpenAI API Key saved successfully to .env file.")
        print("You can now run the agent by executing: python3 chatgpt_agent.py")
    else:
        print("🛑 No API Key provided. The agent will not be able to function.")

if __name__ == "__main__":
    main()
