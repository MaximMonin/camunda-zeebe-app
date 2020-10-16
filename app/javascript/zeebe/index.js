const { ZeebeClient } = require('./client.js');

const Zeebe = new ZeebeClient('/zeebe-rest', '/zeebe-ws');
module.exports = Zeebe;
