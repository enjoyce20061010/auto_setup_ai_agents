const fs = require('fs');
const inquirer = require('inquirer');

const questions = [
  {
    type: 'password',
    name: 'apiKey',
    message: 'Please enter your API Key for the VSCode Agent:',
    mask: '*',
    validate: function (value) {
      if (value.length) {
        return true;
      }
      return 'Please enter a valid API Key.';
    },
  },
];

inquirer.prompt(questions).then((answers) => {
  const envContent = `API_KEY=${answers.apiKey}`;
  fs.writeFileSync('.env', envContent);
  console.log('✅ API Key saved successfully to .env file.');
  console.log('You can now start the agent by running: npm start');
});