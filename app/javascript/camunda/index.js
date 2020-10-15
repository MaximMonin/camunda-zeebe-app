const { CamundaClient } = require('./client.js');

const Camunda = new CamundaClient('/camunda', '/camundaws');
module.exports = Camunda;
