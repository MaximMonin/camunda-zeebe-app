<template>
<div>
    <ul class="nav nav-tabs" style="padding-top: 10px;">
      <li class="nav-item">
        <a class="nav-link active" id="defaultzones-tab" data-toggle="tab" href="#defaultzones">{{ defaultzonelist ()}}</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" id="allzones-tab" data-toggle="tab" href="#allzones" onclick="">{{ fullzonelist ()}}</a>
      </li>
    </ul>
    <div class="tab-content">
      <div class="tab-pane fade show active" id="defaultzones">
        <div class="myfiles2">
           <div class="container social-box" style="margin-top: 0px; padding: 5px">
             <div id="defdomains" class="box" >
               <label class="social-item" style="padding: 5px; width: 150px; margin-bottom: 0px;" v-for="zone in defaultzones">
                  <input type="checkbox" :checked="zone.checked" style="width: 25px">
                  {{zone.name}}
               </label>
             </div>
           </div>
        </div>
      </div>
      <div class="tab-pane fade" id="allzones">
        <div class="myfiles2">
          <div v-for="zonegroup in fullzones">
            <label class="social-item" style="padding: 5px; width: auto; margin-top: 5px">
              <input type="checkbox" :checked="zonegroup.checked" style="width: 25px">
              {{groupname(zonegroup.name)}}
            </label>
            <div class="container social-box" style="margin-top: 0px; padding: 5px">
              <div id="domains" class="box">
                <label class="social-item" style="padding: 5px; width: 200px; margin-bottom: 0px;" v-for="zone in zonegroup.items">
                  <input type="checkbox" :checked="zone.checked" style="width: 25px">
                  {{zone.name}}
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

</div>
</template>
<script>
export default {
  data: function () {
    return {
      defaultzones: [],
      fullzones: []
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
     Event.listen('defaultzones', (data) => {
       this.updateDefaultList (data);
     });
     Event.listen('fullzones', (data) => {
       this.updateFullList (data);
     });
  },
  updated() {
  },
  methods: {
     defaultzonelist: function () {
       var text = {en: 'Zones', ru: "Зоны", uk: "Зони" };
       return text[this.lang];
     },
     fullzonelist: function () {
       var text = {en: 'Other zones', ru: "Другие зоны", uk: "Iнші зони" };
       return text[this.lang];
     },
     groupname: function (group) {
       var text = '';
       if (group == 'ukraine_zone') {
         text = {en: 'Ukranian domains', ru: "Украинские домены", uk: "Українські домени" };
         return text[this.lang];
       }
       if (group == 'international_zone') {
         text = {en: 'International domains', ru: "Международные домены", uk: "Mіжнародні домени" };
         return text[this.lang];
       }
       if (group == 'international_new_zone') {
         text = {en: 'International newTLD', ru: "Международные новые (newTLD)", uk: "Міжнародні нові (newTLD)" };
         return text[this.lang];
       }
       return group;
     },
     updateDefaultList (data) {
       for (var i = 0; i < data.zonelist.length; i++) {
         this.defaultzones.push({name: data.zonelist[i], checked: true});
       }       
       for (var k = 0; k < this.defaultzones.length; k++) {
         var name = this.defaultzones[k].name;
         for (var i = 0; i < this.fullzones.length; i++) {
           for (var j = 0; j < this.fullzone[i].items.length; j++) {
             if (name == this.fullzone[i].items[j].name) {
               this.fullzone[i].items[j].checked = this.defaultzones[k].checked;
             }
           }
         }
       }
     },
     updateFullList (data) {
       for (var i = 0; i < data.zonelist.length; i++) {
         obj = new Array();
         for (var j = 0; j < data.zonelist[i].zonelist.length; j++) {
           var checked = false;
           for (var k = 0; k < this.defaultzones.length; k++) {
             if (data.zonelist[i].zonelist[j] == this.defaultzones[k].name) {
               checked = this.defaultzones[k].checked;
             }
           }
           obj.push ({name: data.zonelist[i].zonelist[j], checked: checked});
         }
         this.fullzones.push({name: data.zonelist[i].name, checked: false, items: obj});
       }       
     },
  },
};
</script>
