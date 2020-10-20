<template>
<div>
  <div class="myfiles2" v-if="domains.length > 0">
     <label class="social-item" style="padding: 5px; width: auto; margin-top: 5px">
        {{registertext()}}
        <button type="button" class="btn btn-link" @click="clear();">{{clearbutton()}}</button>
     </label>
     <div class="container social-box" style="margin-top: 0px; padding: 5px">
       <div id="domains" class="box" v-for="domain in domains">
         <a :href="'http://' + domain.name" @click="open(domain.name);" class="social-item" style="padding: 3px; width: 250px; margin-bottom: 0px;" v-if="domain.status == 'busy'">
            <input type="checkbox" :disabled="domain.disabled" :checked="domain.checked" style="width: 25px">{{domain.name}}
         </a>
         <p class="social-item" style="padding: 3px; width: 250px; margin-bottom: 0px;" v-else>
            <input type="checkbox" :disabled="domain.disabled" :checked="domain.checked" @change="onchange($event, domain.name)" style="width: 25px">{{domain.name}}
         </p>
         <span style="color:green;" v-if="domain.status == 'free'">{{domainstatus(domain.status)}}</span>
         <span style="color:red;"   v-else-if="domain.status == 'busy'">{{domainstatus(domain.status)}}</span>
         <span style=""             v-else>{{domainstatus(domain.status)}}</span>
         <a href="" @click="whois(domain.name);" v-if="domain.status == 'busy'">{{whoistext()}}</a>
       </div>
     </div>
     <div class="box" style="text-align: center; margin-top: 10px; margin-bottom: 10px;" >
        <button type="button" class="btn btn-primary" @click="register();">{{registerbutton()}}</button>
     </div>
  </div>

</div>
</template>
<script>
export default {
  data: function () {
    return {
      domains: []
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
     Event.listen('domainslist', (data) => {
       this.updatelist (data);
     });
     Event.listen('domainsdata', (data) => {
       this.updatedomaindata (data);
     });
  },
  updated() {
  },
  methods: {
     registertext: function () {
       var text = {en: 'Check the required domains and click "Register"', ru: 'Отметьте необходимые домены и нажмите "Зарегистрировать"', uk: 'Відзначте необхідні домени та натисніть "Зареєструвати"' };
       return text[this.lang];
     },
     whoistext: function () {
       var text = {en: 'WhoIs', ru: "Кто", uk: "Хто" };
       return text[this.lang];
     },
     registerbutton: function () {
       var text = {en: 'REGISTER', ru: "ЗАРЕГИСТРИРОВАТЬ", uk: "ЗАРЕЄСТРУВАТИ" };
       return text[this.lang];
     },
     clearbutton: function () {
       var text = {en: 'Clear list', ru: "Очистить", uk: "Очистити" };
       return text[this.lang];
     },
     domainstatus: function (status) {
       var text = status;
       if (status == 'no-data') {
         text = {en: 'No Data', ru: "Нет данных", uk: "Нет даних" };
         return text[this.lang];
       }
       if (status == 'busy') {
         text = {en: 'Busy', ru: "Занят", uk: "Зайнятий" };
         return text[this.lang];
       }
       if (status == 'free') {
         text = {en: 'Free', ru: "Свободен", uk: "Вільний" };
         return text[this.lang];
       }
       return status;
     },   
     clear: function () {
       this.domains = [];
     },
     updatelist (data) {
       for (var i = 0; i < data.length; i++) {
         this.domains.push({name: data[i], checked: false, disabled: true, status: 'no data'});
       }       
     },
     updatedomaindata (data) {
        for (var i = 0; i < this.domains.length; i++) {
         if (data.domain == this.domains[i].name) {
           this.domains[i].status = data.status;
           if (data.status == 'free') {
             this.domains[i].disabled = false;
           }
         }
       }
     },
     onchange: function (e, domain) {
       for (var i = 0; i < this.domains.length; i++) {
         if (this.domains[i].name == domain) {
           this.domains[i].checked = e.target.checked;
         }
       }
     },
     register: function () {    
       event.preventDefault(); 
       obj = new Array ();
       for (var i = 0; i < this.domains.length; i++) {
         if (this.domains[i].checked) {
           obj.push (this.domains[i].name);
         }
       }
       if (obj.length > 0) {
         Event.emit('register-clicked', obj);
       }
     },
     whois: function (domain) {
       event.preventDefault(); 
       Event.emit('whois-clicked', domain);
     },
     open: function (domain) {
       event.preventDefault(); 
       window.open('http://' + domain,'_blank');
     },
  },
};
</script>
