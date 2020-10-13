<template>
    <div class="input-group">
        <b-form-input :placeholder="entertext" dusk="chattext" id="chattext" v-model="newMessage" @keyup.enter="sendMessage"></b-form-input>
        <b-button variant="primary" id="chatattach" @click="getfile">📎</b-button>      
        <b-button id="removefiles" dusk="removefiles" v-if="this.files.length > 0" variant="primary" @click="removeFiles">
        {{ delfiles }}
        </b-button>      
        <b-tooltip v-if="this.files.length > 0" target="removefiles" custom-class="chat-tooltip" triggers="hover">
          <li class="left clearfix" v-for="file in files">
             {{ file.name }} ( {{ Intl.NumberFormat().format(file.size / 1024 / 1024) }} Mb )
             <img v-if="file.mime.match('image*')" class="centered-and-cropped" width="100" height="100" :src="calcurl(file)"/> 
          </li>
        </b-tooltip>
        <input id="file" dusk="chatFile" type="file" class="hiddenfile" @change="uploadFiles" ref="myFiles" multiple="yes"/>
        <b-button dusk="sendMessage" id="sendmessage" variant="primary" @click="sendMessage">➣</b-button>
    </div>
</template>
<style>
.hiddenfile {
    display: none;
}
.chat-tooltip > .tooltip-inner{
  /* Removes the default max-width */
  max-width: none;
  padding: 5px;
}
</style>
<script>
  export default {
    props: ['chat'],
    data() {
        return {
            newMessage: '',
            files: [],
        }
    },
    computed: {
      user: function () {
        return this.$store.state.user;
      },
      lang: function () {
        return this.$store.state.lang;
      },
      baseurl: function () {
        return this.$store.state.baseurl;
      },
      entertext: function () {
        var text = {en: 'Enter message', ru: "Введите сообщение", uk: "Введіть повідомлення" };
        return text[this.lang];
      },
      delfiles: function () {
        var text = {en: 'Delete', ru: "Удалить", uk: "Видалити" };
        return text[this.lang] + ' (' + this.files.length + ')';
      },
    },
    methods: {
      getfile () {
        this.$refs.myFiles.click();
      },
      calcurl (file) {
        if (file.preview) {
          return this.baseurl + '/' + file.preview;
        } 
        return this.baseurl + '/' + file.url;
      },
      uploadFiles () {
        var filelist = this.$refs.myFiles.files;
        var fl= filelist.length;
        var i=0;

        while ( i < fl) {
          var file = filelist[i];
          var isfound;
          var j;
          isfound = false;
          for (j = 0; j < this.files.length; j++) {
            if (this.files[j].name == file.name) {
               isfound = true;
            }
          }
          i++;
          if (!isfound) {
            var formData = new FormData();
            formData.append("file", file);
            axios.post('/upload/local?todo=chat', formData, {
                  headers: { 'Content-Type': 'multipart/form-data' }
            }).then(response => {
               var isfound;
               var j;
               isfound = false;
               for (j = 0; j < this.files.length; j++) {
                 if (this.files[j].url == (response.path + '/' + response.data.name) ) {
                    isfound = true;
                 }
               }
               if (!isfound) {
                 var preview;
                 if (response.data.preview) {
                   preview = response.data.path + '/' + response.data.preview;
                 }
                 this.files.push ({
                    name: response.data.originalname,
                    mime: response.data.mime_type,
                    size: response.data.filesize,
                    url: response.data.path + '/' +  response.data.name,
                    preview: preview
                 });
               }
            });
          }
        }    
      },
      removeFiles () {
        var filelist = this.files;
        var fl = filelist.length;
        var i = 0;

        while ( i < fl) {
          var file = filelist[i];
          i++;
          axios.post('/upload/local/delete', {file: file.url});
          if (file.preview) {
            axios.post('/upload/local/delete', {file: file.preview});
          }
        }
        this.files = [];
      },
      sendMessage() {
        if (this.newMessage || this.files.length > 0) {
                  Event.emit('newchatmessage', {
                    user: this.user,
                    username: this.user.username,
                    avatar: this.user.avatar,
                    message: this.newMessage,
                    files: this.files,
                    chat_id: this.chat,
                    created_at: new Date(),
                  });
        }
        this.newMessage = '';
        this.files = [];
      },
    }
 }
</script>
