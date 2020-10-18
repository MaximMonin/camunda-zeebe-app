const { CamundaClient } = require('./client.js');

const Camunda = new CamundaClient('/camunda-ws');
module.exports = Camunda;
