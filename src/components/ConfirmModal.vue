<template>
  <div></div>
</template>
<script>
import { defineComponent } from "vue";
import { useQuasar } from "quasar";
import { dialogBtnCancel, dialogBtnDanger } from "src/utils/appDialog";

export default defineComponent({
  name: "ConfirmModal",
  props: {},
  setup() {
    const $q = useQuasar();

    function confirm() {
      return new Promise((res, rej) => {
        $q.dialog({
          title: "Confirmar eliminación",
          message:
            "¿Está seguro de eliminar este registro? Esta acción no se puede deshacer.",
          cancel: dialogBtnCancel(),
          ok: dialogBtnDanger("Eliminar"),
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
