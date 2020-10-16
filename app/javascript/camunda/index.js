const { CamundaClient } = require('./client.js');

const Camunda = new CamundaClient('/camunda-rest', '/camunda-ws');
module.exports = Camunda;
