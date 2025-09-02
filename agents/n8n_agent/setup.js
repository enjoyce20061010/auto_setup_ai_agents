const fs = require('fs');
const path = require('path');
const readline = require('readline');

const envPath = path.join(__dirname, '.env');
const configPath = path.join(process.env.HOME, '.n8n', 'config');

function ask(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  return new Promise(resolve => rl.question(question, ans => {
    rl.close();
    resolve(ans);
  }));
}

async function main() {
  let encryptionKey = '';
  if (fs.existsSync(configPath)) {
    const config = fs.readFileSync(configPath, 'utf8');
    const match = config.match(/N8N_ENCRYPTION_KEY=(.+)/);
    if (match) {
      encryptionKey = match[1];
      console.log('已從 ~/.n8n/config 讀取 N8N_ENCRYPTION_KEY');
    }
  }
  if (!encryptionKey) {
    encryptionKey = await ask('請輸入 N8N_ENCRYPTION_KEY（可留空自動生成）: ');
    if (!encryptionKey) {
      encryptionKey = Math.random().toString(36).slice(2) + Math.random().toString(36).slice(2);
      console.log('已自動生成 N8N_ENCRYPTION_KEY: ' + encryptionKey);
    }
  }

  let dbType = await ask('是否需要進階資料庫設定？輸入資料庫類型（留空跳過）: ');
  let dbConfig = '';
  if (dbType) {
    dbConfig = await ask('請輸入資料庫連線字串: ');
  }

  let apiKey = await ask('請輸入 n8n API 金鑰（留空跳過）: ');

  let envContent = `N8N_ENCRYPTION_KEY=${encryptionKey}\n`;
  if (dbType && dbConfig) {
    envContent += `DB_TYPE=${dbType}\nDB_CONNECTION=${dbConfig}\n`;
  }
  if (apiKey) {
    envContent += `N8N_API_KEY=${apiKey}\n`;
  }

  fs.writeFileSync(envPath, envContent);
  console.log('.env 檔案已寫入完成。');
}

main();
