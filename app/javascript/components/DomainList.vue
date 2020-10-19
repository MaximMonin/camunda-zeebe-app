<template>
<div>
  <div class="myfiles2" v-if="domains.length > 0">
     <label class="social-item" style="padding: 5px; width: auto; margin-top: 5px">
        {{registertext()}}
     </label>
     <div class="container social-box" style="margin-top: 0px; padding: 5px">
       <div id="domains" class="box" v-for="domain in domains">
         <a class="social-item" style="padding: 5px; width: 300px; margin-bottom: 0px;">
            <input type="checkbox" :disabled="domain.disabled" :checked="domain.checked" @change="onchange($event, domain.name)" style="width: 25px">
            {{domain.name}}
         </a>
         <a href="" @click="whois(domain.name);">{{whoistext()}}</a>
       </div>
     </div>
     <button type="button" class="btn btn-primary" @click="register();">{{registerbutton()}}</button>
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
       var text = {en: 'Who is', ru: "Кто это", uk: "Хто це" };
       return text[this.lang];
     },
     registerbutton: function () {
       var text = {en: 'REGISTER', ru: "ЗАРЕГИСТРИРОВАТЬ", uk: "ЗАРЕЄСТРУВАТИ" };
       return text[this.lang];
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
  },
};
</script>
