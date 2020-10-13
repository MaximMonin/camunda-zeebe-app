<template>
  <div class="chat-client-conversation" ref="id" @scroll="handleScroll">
    <ul class="chat">
        <li class="left clearfix" v-for="message in orderedmessages">
           <div class="chatrow">
 	     <div v-if="(message.avatar)">
               <img class="centered-and-cropped" width="30" height="30" style="border-radius:50%" :src="message.avatar"> 
	     </div>
	     <div v-else>
               <b-avatar variant="info" :text="avatartext(message.username)"></b-avatar>
	     </div>
             <p>
                  {{ message.message }}
                  <span class="chattime">
                     {{ realdate(message.created_at) }}
                  </span>
             </p>
             
           </div>
           <div v-if="(message.files)">
             <div class="chatfiles" v-for="file in JSON.parse(message.files)">
                <img v-if="file.mime.match('image*')" class="centered-and-cropped" width="300" height="300" :src="calcurl(file)"/> 
                <a :href="baseurl + '/' + file.url" target="_blank">
                   {{file.name}}
                </a>
             </div>
           </div>
        </li>
    </ul>
  </div>
</template>
<style>
        .centered-and-cropped { 
           object-fit: cover; 
        }
        .chat {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        .chat li {
            padding-bottom: 0px;
        }
        .chat li div {
            margin-left: 1px;
            color: #777777;
        }
        .chatrow {
           display: flex;
           flex-wrap: nowrap;
        }
        .chatfiles {
            padding: 5px;
        }
        .chattime {
           padding-left: 30px;
           font-size: 50%;
        }
        .chat li p {
	    border-radius: 0.5rem 0.5rem 0.5rem 0.5rem;
	    background: white;
            margin-left: 10px;
            margin-right: 20px;
            font-size: 100%;
        }
        .chat-client-conversation {
           padding: 0 5px;
           overflow-y: auto;
           overflow-x: hidden;
           position: absolute;
           bottom: 0; left: 0; right: 0;
           max-height: 100%;
        }
        ::-webkit-scrollbar-track {
            -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
            background-color: #F5F5F5;
        }
        ::-webkit-scrollbar {
            width: 3px;
            background-color: #F5F5F5;
        }
        ::-webkit-scrollbar-thumb {
            -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,.3);
            background-color: #555;
        }
</style>
<script>
export default {
  props: ['chat'],
  data: function () {
    return {
      messages: [],
      pages: 0,
      isLoading: false,
      allPages: false,
    }
  },
  computed: {
    user: function () {
      return this.$store.state.user;
    },
    baseurl: function () {
      return this.$store.state.baseurl;
    },
    orderedmessages: function () {
      return _.orderBy(this.messages, 'id')
    },
  },
  beforeDestroy() {
     this.$cable.connection.disconnect();
  },
  channels: {
    chat_channel_private: {
      received(data) {
        this.messages.push({
             id: data.message.id,
             message: data.message.message,
             files: data.message.files,
             created_at: data.message.created_at,
             username: data.username,
             avatar: data.avatar,
           });
      }
    }
  },
  mounted() {
     this.$cable.connection.connect();
     this.$cable.subscribe({
        channel: 'ChatChannel',
        chat: this.chat
      },
      'chat_channel_private'
     );

     this.fetchMessages ();

     Event.listen('newchatmessage', (message) => {
       this.PostMessage(message)
     });

     this.scrollToBottom();
     this.pages = parseInt (this.messages.length / 50, 10);
  },
  updated() {
     if (this.isLoading == false) {
       this.scrollToBottom();
     }
     this.pages = parseInt (this.messages.length / 50, 10);    
     this.isLoading = false;
  },

  methods: {
        avatartext: function (name) {
          return name.split(' ').map(function(str) { return str ? str[0].toUpperCase() : "";}).join('');
        },
        calcurl (file) {
          if (file.preview) {
            return this.baseurl + '/' + file.preview;
          } 
          return this.baseurl + '/' + file.url;
        },
        realdate: function (dtstring) {
           var d = new Date(dtstring);
           var dt = new Date();
           if (((dt - d) / 1000 / 60) > 12 * 60 ) { 
             // More than 12 hours ago 
             dtstring = this.pad2(d.getDate()) + '-' + this.pad2(d.getMonth()+1) + '-' + d.getFullYear()
               + ' ' + this.pad2(d.getHours())  + ':' + this.pad2(d.getMinutes());
             return dtstring;
           }
           return this.pad2(d.getHours())  + ':' + this.pad2(d.getMinutes());
        },
        pad2: function (number) {
           var length = 2;
           var str = '' + number;
           while (str.length < length) {
             str = '0' + str;
           } 
           return str;
        },
        PostMessage(message) {
            var files = message.files;
            message.files = JSON.stringify(files);

            axios.post('/chat_messages', message).then(response => {});
        },
        scrollToBottom () {
            this.$refs.id.scrollTop = this.$refs.id.scrollHeight;
        },
        fetchMessages () {
          axios.get('/chat_messages/' + this.chat + '?page=1' ).then(response => {
            if (response !== null) {
              var i;
              for (i = 0; i < response.data.length; i++) {
                 this.messages.push(response.data[i]);
              }
            }
          });
        },
        handleScroll: _.throttle (function () {
           // Autoload old messages while scrolling up
           if (this.$refs.id.scrollTop < 500 && this.isLoading == false && this.allPages == false) 
           {
             this.isLoading = true;
             axios.get('/chat_messages/' + this.chat + '?page=' + (this.pages + 1) ).then(response => {
               if (response !== null) {
                 var i;
                 var j;
                 var isfound;
                 // Check message in array already 
                 for (i = 0; i < response.data.length; i++) {
                   isfound = false;
                   for (j = 0; j < this.messages.length; j++) {
                     if (this.messages[j].id == response.data[i].id) {
                       isfound = true;
                     }
                   }
                   if (!isfound) {
                     this.messages.push(response.data[i]);
                   }
                 }
               }
               if (response == null) {
                 this.allPages = true;   
               }
             });
           }
        }, 1000),
  },
};
</script>
