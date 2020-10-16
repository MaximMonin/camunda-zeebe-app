const axios = require('axios');
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
import { createConsumer } from "@rails/actioncable"
const { v4: uuidv4 } = require('uuid');

class ZeebeClient {
  constructor(url, wsurl) {
    this.url = url;
    this.consumer = createConsumer ( wsurl );
    this.processId = null;
    this.businessKey = null;
    this.processKey = null;
  };
  async startProcess(ProcessKey, Variables, callback) {
    this.processKey = ProcessKey;
    this.BusinessKey = ProcessKey + "-" + uuidv4();
    await axios.post( this.url + '/process-definition/key/' + ProcessKey + '/start', {variables: Variables, businessKey: this.BusinessKey})
    .then(response => {
     const data = response.data;
     console.log('Workflow instance started: ' + JSON.stringify(data));
     this.processId = data.id;
     this.processKey = ProcessKey;
     this.businessKey = data.businessKey;
     this.consumer.subscriptions.create({ channel: "Zeebe", room: this.businessKey },
     {
       connected() {
         console.log ('ws connection established');
       },
       disconnected() {
         console.log ('ws connection closed');
       },
       received(data) {
         callback(data);
       },
     });

     return data;
    })
    .catch(error => {
      if (error.response) {
        console.log(error.response.data);
      }
      return error;
    });
  };
  async startProcessWithResult(ProcessKey, Variables) {
    this.processKey = ProcessKey;
    this.BusinessKey = ProcessKey + uuidv4();
    await axios.post( this.url + '/process-definition/key/' + ProcessKey + '/startwithresult', {variables: variables, businessKey: BusinessKey})
    .then(response => {
      const data = response.data;
      return data;
    })
    .catch(error => {
      if (error.response) {
        console.log(error.response.data);
      }
      return error;
    });
  };
};

export {
  ZeebeClient
}
