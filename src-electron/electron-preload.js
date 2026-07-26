const { contextBridge, ipcRenderer } = require("electron");
contextBridge.exposeInMainWorld("myAPI", {
  //Sp General ejecucion ST
  executeSp_St: (data, sp) =>
    ipcRenderer.invoke("myAPI:executeSp_St", data, sp),

  //Sp General ejecucion DS
  executeSp_Dt: (data, sp) =>
    ipcRenderer.invoke("myAPI:executeSp_Dt", data, sp),

  //Sp General ejecucion DS
  executeSp_Ds: (data, sp) =>
    ipcRenderer.invoke("myAPI:executeSp_Ds", data, sp),

  convertToDocx: (dataDoc) =>
    ipcRenderer.invoke("myAPI:convertTo_Docx", dataDoc),

  convertToDocxZip: (dataDoc) =>
    ipcRenderer.invoke("myAPI:convertTo_Docx_Zip", dataDoc),

  // metodo para exportar la data de la tabla en un excel
  ExportData: (dataDoc) => ipcRenderer.invoke("myAPI:Export_Data", dataDoc),

  openFileTemplate: () => ipcRenderer.invoke("myAPI:openFilesTemplates"),
});

contextBridge.exposeInMainWorld("ApiLogin", {
  loadLogin: (datosUser) => ipcRenderer.invoke("ApiLogin:login", datosUser),
  loadModules: (perfil) => ipcRenderer.invoke("ApiLogin:Load_Modules", perfil),
  changeDatabase: (db) => ipcRenderer.invoke("ApiLogin:change_Database", db),
  getConfigParroquia: () => ipcRenderer.invoke("ApiLogin:getConfigParroquia"),
});

contextBridge.exposeInMainWorld("ApiSetup", {
  isConfigured: () => ipcRenderer.invoke("ApiSetup:isConfigured"),
  getPublicConfig: () => ipcRenderer.invoke("ApiSetup:getPublicConfig"),
  testConnection: (sqlConfig) =>
    ipcRenderer.invoke("ApiSetup:testConnection", sqlConfig),
  pickImage: (kind) => ipcRenderer.invoke("ApiSetup:pickImage", kind),
  getAssetDataUrl: (filename) =>
    ipcRenderer.invoke("ApiSetup:getAssetDataUrl", filename),
  saveConfig: (payload) => ipcRenderer.invoke("ApiSetup:saveConfig", payload),
});
