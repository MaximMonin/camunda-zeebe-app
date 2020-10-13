<template>
  <div class="photos-view">
    <div class="photos" v-for="file in files">
      <div class="FileContainer">
            <div>
               <img class="centered-and-cropped" width="200" height="200" loading="lazy" :src="calcurl(file)"/> 
            </div>
            <div class="FileButton">
               <a v-if="editmode == false" :href="baseurl + '/' + file.file" target="_blank">{{ opentext() }}</a>
               <button v-if="editmode == true" type="button" class="btn btn-link" @click="removeFile(file)">{{ deltext() }}</button>
            </div>
      </div>
    </div>
  </div>
</template>
<style>
        .centered-and-cropped { 
           object-fit: cover; 
        }
        .FileButton{
           text-align:center;
        }
        .photos-view {
           display: flex;
           flex-wrap: wrap;
           overflow-y: auto;
           overflow-x: hidden;
           max-height: 100%;
        }
        .photos {
            margin: 0;
            padding: 5px;
        }
</style>
<script>
export default {
  data: function () {
    return {
      files: [],
      pages: 0,
      isLoading: false,
      allPages: false,
      editmode: false,
    }
  },
  computed: {
    baseurl: function () {
      return this.$store.state.baseurl;
    },
    lang: function () {
      return this.$store.state.lang;
    },
  },
  mounted() {
     this.fetchFiles ();
     this.pages = parseInt (this.files.length / 20, 10);
     window.addEventListener("scroll", this.handleScroll); 
     Event.listen('newfileadded', () => {
       this.updateFiles ();
     });
     Event.listen('fileseditmode', () => {
       this.editmode = true;
     });
     Event.listen('filesviewmode', () => {
       this.editmode = false;
     });
  },
  updated() {
     this.pages = parseInt (this.files.length / 20, 10);    
     this.isLoading = false;
  },
  beforeDestroy() {
     window.removeEventListener('scroll', this.handleScroll);
  },
  methods: {
        calcurl (file) {
          if (file.filepreview) {
            return this.baseurl + '/' + file.filepreview;
          } 
          return this.baseurl + '/' + file.file;
        },
        opentext: function () {
          var text = {en: 'Open', ru: "Открыть", uk: "Відкрити" };
          return text[this.lang];
        },
        deltext: function () {
          var text = {en: 'Delete', ru: "Удалить", uk: "Видалити" };
          return text[this.lang];
        },
        fetchFiles () {
          axios.get('/user_files/photos?page=1').then(response => {
            if (response !== null) {
              var i;
              var j;
              var isfound;
              for (i = 0; i < response.data.length; i++) {
                isfound = false;
                for (j = 0; j < this.files.length; j++) {
                  if (this.files[j].id == response.data[i].id) {
                    isfound = true;
                  }
                }
                if (!isfound) {
                  this.files.push(response.data[i]);
                }
              }
            }
          });
        },
        updateFiles () {
          this.files = [];
          this.pages = 0;
          this.isLoading = false;
          this.allPages = false;
          this.fetchFiles ();
        },
        removeFile (file) {
          axios.post('/upload/local/delete', {file: file.file});
          if (file.filepreview) {
            axios.post('/upload/local/delete', {file: file.filepreview});
          }
          var j;
          for (j = 0; j < this.files.length; j++) {
            if (this.files[j].id == file.id) {
               this.files.splice(j, 1);
               return;
            }
          }
        },
        handleScroll: _.throttle (function () {
           // Autoload new files while scrolling down
           const scrollY = window.scrollY;
           const visible = document.documentElement.clientHeight;
           const pageHeight = document.documentElement.scrollHeight;
           if (visible + scrollY + 100 >= pageHeight && this.isLoading == false && this.allPages == false) 
           {
             this.isLoading = true;
             axios.get('/user_files/photos?page=' + (this.pages + 1) ).then(response => {
               if (response !== null) {
                 var i;
                 var j;
                 var isfound;
                 // Check files in array already 
                 for (i = 0; i < response.data.length; i++) {
                   isfound = false;
                   for (j = 0; j < this.files.length; j++) {
                     if (this.files[j].id == response.data[i].id) {
                       isfound = true;
                     }
                   }
                   if (!isfound) {
                     this.files.push(response.data[i]);
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
