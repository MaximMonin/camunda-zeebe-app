const axios = require('axios');
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

class CamundaClient {
  constructor(url, wsurl) {
    this.url = url;
    this.wsurl = wsurl
    this.socket = null;
    this.processId = null;
    this.processKey = null;
    this.callback = null;
  };
  async startProcess(ProcessKey, Variables, callback) {
    this.processKey = ProcessKey;
    this.OpenSocket (callback);
 
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
  async publishMessage (messageName, Variables, callback) {
    this.OpenSocket (callback);
    await axios.post( this.url + '/engine-rest/message', {messageName: messageName, processInstanceId: this.processId, processVariables: Variables})
    .then(response => {
     const data = response.data;
     console.log('Message delivered: ' + JSON.stringify(data));
     return data;
    })
    .catch(error => {
      if (error.response) {
        console.log(error.response.data);
      }
      return error;
    });

  }
  OpenSocket (callback) {
    this.callback = callback;
    if (this.socket && this.socket.readyState == 1) {
      return;
    }
    try {
      var wsUrl = '';
      if (window.location.protocol == 'http:') {
        wsUrl = 'ws://' + window.location.host + '/' + this.wsurl;
      }
      else {
        wsUrl = 'wss://' + window.location.host + '/' + this.wsurl;
      }
      var socket = new WebSocket(wsUrl, ["Camunda"]);
      this.socket = socket;
      // Соединение открыто
      socket.onopen = function (event) {
        console.log ('ws connection opened');
      };
      socket.onclose = function(event) {
        console.log ('ws connection closed');
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
  }
};

export {
  CamundaClient
}
