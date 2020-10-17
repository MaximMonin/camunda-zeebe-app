const axios = require('axios');
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

class CamundaClient {
  constructor(url, wsurl) {
    this.url = url;
    this.wsurl = wsurl
    this.socket = null;
    this.socketstatus = 0;
    this.processId = null;
    this.processKey = null;
  };
  async startProcess(ProcessKey, Variables, callback) {
    this.processKey = ProcessKey;
    try {
      var socket = new WebSocket("ws://195.39.196.61:2586/", ["Camunda"]);
      this.socket = socket;
      // Соединение открыто
      socket.onopen = function (event) {
        console.log ('ws connection opened');
        this.socketstatus = 1;
      };
      socket.onclose = function(event) {
        console.log ('ws connection closed');
        this.socketstatus = 0;
      };
      socket.onerror = function (error) {
        console.log('ws error ' + error);
      };
      socket.onmessage = function (event) {
        if (event.data === undefined) {
           return;
        }
        if (event.data == 'welcome') {
          socket.send ("welcome");
          return;
        }
        if (this.processId == event.data.processId) {
          callback (event.data);
        }
      };
    }
    catch (e) {
      console.log(e);
    }
 
    await axios.post( this.url + '/engine-rest/process-definition/key/' + ProcessKey + '/start', {variables: Variables})
    .then(response => {
     const data = response.data;
     console.log('Workflow instance started: ' + JSON.stringify(data));
     this.processId = data.id;
     this.socket.send (JSON.stringify({command: 'subscribe', channel: 'Camunda', processId: this.processId}));
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
  CamundaClient
}
