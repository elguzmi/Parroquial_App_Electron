<template>
  <div></div>
</template>
<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";

export default defineComponent({
  name: "ConfirmModal",
  props: {},
  setup() {
    const $q = useQuasar();

    function confirm() {
      return new Promise((res, rej) => {
        $q.dialog({
          title: "Confirm",
          message: "Esta seguro de eliminar el registro?",
          cancel: true,
          persistent: true,
        })
          .onOk(() => {
            res();
          })
          .onCancel(() => {
            rej();
          });
      });
    }

    return {
      confirm,
    };
  },

  mounted() {},
  methods: {},
});
</script>
