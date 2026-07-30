const routes = [
  {
    path: "/setup",
    component: () => import("layouts/SetupLayout.vue"),
    children: [
      {
        path: "",
        redirect: "/setup/database",
      },
      {
        path: "database",
        component: () => import("pages/setup/SetupDatabase.vue"),
      },
      {
        path: "parroquia",
        component: () => import("pages/setup/SetupParroquia.vue"),
      },
    ],
  },
  {
    path: "/Home",
    component: () => import("layouts/MainLayout.vue"),
    children: [
      { path: "/Inicio", component: () => import("pages/Index.vue") },
      {
        path: "/Bautismos",
        component: () => import("pages/Bautismos.vue"),
        props: true,
      },
      {
        path: "/Confirmaciones",
        component: () => import("pages/Confirmaciones.vue"),
      },
      {
        path: "/Matrimonios",
        component: () => import("pages/Matrimonios.vue"),
      },
      {
        path: "/Defunciones",
        component: () => import("pages/Defunciones.vue"),
      },
      {
        path: "/Configuracion",
        component: () => import("pages/Configuracion.vue"),
      },
      {
        path: "/AcercaDe",
        component: () => import("pages/AcercaDe.vue"),
      },
    ],
  },

  {
    path: "/",
    component: () => import("pages/Login.vue"),
  },
  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/Error404.vue"),
  },
];

export default routes;
