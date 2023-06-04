<template>
  <router-view />
</template>
<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";

export default defineComponent({
  name: "App",
  setup() {
    const q = useQuasar();

    function LoadingAction(action) {
      if (action == 1) q.loading.show();
      else q.loading.hide();
    }
    return {
      LoadingAction,
    };
  },
  methods: {
    pruebaFn() {},
  },
});
</script>
