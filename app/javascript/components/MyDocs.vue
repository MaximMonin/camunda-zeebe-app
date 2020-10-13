<template>
  <div class="docs-view">
    <table v-if="files.length > 0" class="table">
      <thead>
        <tr>
          <th>{{ filetext() }}</th>
          <th>{{ sizetext() }}</th>
          <th>{{ actiontext() }}</th>
        </tr>
      </thead>
      <tbody v-for="file in files">
        <tr>
          <td>{{ file.filename }}</td>
          <td>{{ Intl.NumberFormat().format(file.filesize / 1024 / 1024) }} Mb</td>
          <td>
            <div class="TableFileButton">
               <a v-if="editmode == false" :href="baseurl + '/' + file.file" target="_blank">{{ opentext() }}</a>
               <button v-if="editmode == true" type="button" class="btn btn-link btn-sm" @click="removeFile(file)">{{ deltext() }}</button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<style>
        .TableFileButton{
           text-align:left;
        }
        .docs-view {
           display: flex;
           flex-wrap: wrap;
           overflow-y: auto;
           overflow-x: hidden;
           max-height: 100%;
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
        opentext: function () {
          var text = {en: 'Open', ru: "Открыть", uk: "Відкрити" };
          return text[this.lang];
        },
        deltext: function () {
          var text = {en: 'Delete', ru: "Удалить", uk: "Видалити" };
          return text[this.lang];
        },
        filetext: function () {
          var text = {en: 'Filename', ru: "Имя файла", uk: "Ім'я файлу" };
          return text[this.lang];
        },
        sizetext: function () {
          var text = {en: 'Size', ru: "Размер", uk: "Розмір" };
          return text[this.lang];
        },
        actiontext: function () {
          var text = {en: 'Action', ru: "Действие", uk: "Дія" };
          return text[this.lang];
        },
        fetchFiles () {
          axios.get('/user_files/docs?page=1').then(response => {
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
             axios.get('/user_files/docs?page=' + (this.pages + 1) ).then(response => {
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
