const fs = require('fs');
const path = require('path');
const os = require('os');
const inquirer = require('inquirer');

async function main() {
  console.log('--- n8n Agent Setup ---');

  const n8nConfigPath = path.join(os.homedir(), '.n8n', 'config');
  let envContent = '# n8n Environment Configuration\n';

  if (fs.existsSync(n8nConfigPath)) {
    try {
      const n8nConfig = JSON.parse(fs.readFileSync(n8nConfigPath, 'utf8'));
      if (n8nConfig.encryptionKey) {
        envContent += `N8N_ENCRYPTION_KEY=${n8nConfig.encryptionKey}\n`;
        console.log('🔑 Found existing N8N_ENCRYPTION_KEY in ~/.n8n/config and saved it to .env file.');
      } else {
        console.error('🛑 Error: encryptionKey not found in ~/.n8n/config.');
        console.log('Please ensure your n8n instance has been run at least once to generate a key.');
        return;
      }
    } catch (error) {
      console.error(`🛑 Error reading or parsing ~/.n8n/config: ${error.message}`);
      return;
    }
  } else {
    console.error('🛑 Error: n8n config file not found at ~/.n8n/config.');
    console.log('Please run n8n at least once to generate the necessary configuration and encryption key before running this setup.');
    return;
  }

  const { useAdvancedSetup } = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'useAdvancedSetup',
      message: 'Do you want to configure advanced settings (like a database) now?',
      default: false,
    },
  ]);

  if (useAdvancedSetup) {
    const { dbType } = await inquirer.prompt([{
        type: 'list',
        name: 'dbType',
        message: 'Which database do you want to use?',
        choices: ['None (use default SQLite)', 'PostgreSQL', 'MySQL'],
    }]);

    if (dbType !== 'None (use default SQLite)') {
        const dbQuestions = [
            { type: 'input', name: 'host', message: 'Database Host:', default: 'localhost' },
            { type: 'input', name: 'port', message: 'Database Port:', default: dbType === 'PostgreSQL' ? 5432 : 3306 },
            { type: 'input', name: 'database', message: 'Database Name:' },
            { type: 'input', name: 'user', message: 'Database User:' },
            { type: 'password', name: 'password', message: 'Database Password:', mask: '*' },
        ];
        const dbAnswers = await inquirer.prompt(dbQuestions);
        const dbPrefix = dbType === 'PostgreSQL' ? 'DB_POSTGRESDB' : 'DB_MYSQL';
        envContent += `DB_TYPE=${dbType.toLowerCase()}db\n`;
        envContent += `${dbPrefix}_HOST=${dbAnswers.host}\n`;
        envContent += `${dbPrefix}_PORT=${dbAnswers.port}\n`;
        envContent += `${dbPrefix}_DATABASE=${dbAnswers.database}\n`;
        envContent += `${dbPrefix}_USER=${dbAnswers.user}\n`;
        envContent += `${dbPrefix}_PASSWORD=${dbAnswers.password}\n`;
    }
  }

  const { addApiKeys } = await inquirer.prompt([{
      type: 'confirm',
      name: 'addApiKeys',
      message: 'Do you want to add any API keys (e.g., OPENAI_API_KEY) as environment variables now?',
      default: false,
  }]);

  if (addApiKeys) {
      const { apiKeysStr } = await inquirer.prompt([{
          type: 'input',
          name: 'apiKeysStr',
          message: 'Enter your keys in KEY=VALUE format, separated by commas (e.g., OPENAI_API_KEY=sk-..., ANOTHER_KEY=...):'
      }]);
      const pairs = apiKeysStr.split(',');
      pairs.forEach(pair => {
          if(pair.includes('=')) {
              envContent += `${pair.trim()}\n`;
          }
      });
  }

  fs.writeFileSync('.env', envContent);
  console.log('✅ n8n configuration saved successfully to .env file.');
  console.log('You can now start the agent by running: npm start');
}

main();
