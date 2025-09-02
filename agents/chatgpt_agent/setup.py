import os
from pathlib import Path

def main():
    env_path = Path(__file__).parent / '.env'
    if env_path.exists():
        overwrite = input('.env 檔案已存在，是否覆蓋？(y/N): ')
        if overwrite.lower() != 'y':
            print('已取消覆蓋 .env 檔案。')
            return
    api_key = input('請輸入 OpenAI API 金鑰: ')
    with open(env_path, 'w') as f:
        f.write(f'OPENAI_API_KEY={api_key}\n')
    print('.env 檔案已寫入完成。')

if __name__ == '__main__':
    main()
