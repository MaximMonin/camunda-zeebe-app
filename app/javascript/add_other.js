window.Dropzone = require('dropzone');
/**
 * We'll load the axios HTTP library which allows us to easily issue requests
 * to our back-end. This library automatically handles sending the
 * CSRF token as a header based on the value of the "XSRF" token cookie.
 */

window.axios = require('axios');
window.axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

if (document.querySelector("meta[name='csrf-token']"))
{
  const csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");
  window.axios.defaults.headers.common['X-CSRF-Token'] = csrf;
}

window.ImmediateUploader = require('./upload');

window.Camunda = require('./camunda');
window.Zeebe = require('./zeebe');
