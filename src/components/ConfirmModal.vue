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
          title: "Confirmar eliminación",
          message: "¿Está seguro de eliminar este registro? Esta acción no se puede deshacer.",
          cancel: { label: "Cancelar", flat: true },
          ok: { label: "Eliminar", color: "negative" },
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
