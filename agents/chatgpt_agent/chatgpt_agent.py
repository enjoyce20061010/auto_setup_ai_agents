import openai

class ChatGPTEngine:
    def __init__(self, api_key):
        self.api_key = api_key
        openai.api_key = self.api_key

    def get_response(self, prompt):
        response = openai.Completion.create(
            engine="davinci",
            prompt=prompt,
            max_tokens=150
        )
        return response.choices[0].text.strip()

if __name__ == "__main__":
    # Replace with your OpenAI API key
    api_key = "YOUR_OPENAI_API_KEY"
    engine = ChatGPTEngine(api_key)
    response = engine.get_response("Hello, world!")
    print(response)