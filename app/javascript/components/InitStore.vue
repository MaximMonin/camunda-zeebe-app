<template>
</template>

<script>
  export default {
     mounted() {
        this.initstore ();
     },
     methods: {
        initstore () {
          axios.get('/initstore').then(response => {
            if (response !== null) 
            {
              this.$store.commit ('changelanguage', response.data.lang);
              if (response.data.user)
                this.$store.commit ('login', response.data.user);
              else
                this.$store.commit ('logout');
              this.$store.commit ('setbaseurl', response.data.baseurl);

              var dt = response.data.servertime;
              var d = new Date();
              var loc = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds());
              var time_zone = ((loc/1000 - dt/1000)/60).toFixed(0);

              this.$store.commit ('settimezone', time_zone);
            }
          });
        },
     }
  }
</script>
