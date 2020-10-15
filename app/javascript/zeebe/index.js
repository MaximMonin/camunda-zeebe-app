const { ZeebeClient } = require('./client.js');

const Zeebe = new ZeebeClient('/zeebe', '/zeebews');
module.exports = Zeebe;
