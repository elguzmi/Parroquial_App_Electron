/**
 * This file is used specifically for security reasons.
 * Here you can access Nodejs stuff and inject functionality into
 * the renderer thread (accessible there through the "window" object)
 *
 * WARNING!
 * If you import anything from node_modules, then make sure that the package is specified
 * in package.json > dependencies and NOT in devDependencies
 *
 * Example (injects window.myAPI.doAThing() into renderer thread):
 *
 *   import { contextBridge } from 'electron'
 *
 *   contextBridge.exposeInMainWorld('myAPI', {
 *     doAThing: () => {}
 *   })
 */

//window.Electron = require("electron");
const { contextBridge, ipcRenderer } = require("electron");
contextBridge.exposeInMainWorld("myAPI", {
  // cargar ministros
  loadMinistros: () => ipcRenderer.invoke("myAPI:load_Ministros"),
  loadFirmantes: () => ipcRenderer.invoke("myAPI:load_Firmantes"),

  //conseguir registro para impirmir
  getRecord: (data) => ipcRenderer.invoke("myAPI:get_Record"),

  //Insercion de datos
  insRecord: (data, tabla) =>
    ipcRenderer.invoke("myAPI:ins_Record", data, tabla),

  //Actualizar de datos
  updRecord: (data, tabla) =>
    ipcRenderer.invoke("myAPI:upd_Record", data, tabla),

  //actualizar Configuraciones
  insConfig: (data, sp) => ipcRenderer.invoke("myAPI:ins_Config", data, sp),

  //Sp General ejecucion ST
  executeSp_St: (data, sp) =>
    ipcRenderer.invoke("myAPI:executeSp_St", data, sp),

  //Inactivar de datos
  InvtRecord: (data) => ipcRenderer.invoke("myAPI:Invt_Record", data),

  //Get Documento
  GetDocumentoHtml: (Tabla, Id) =>
    ipcRenderer.invoke("myAPI:Get_DocumentoHtml", Tabla, Id),
  goToPdf: (dataDoc) => ipcRenderer.invoke("myAPI:GoTo_DocumentoPdf", dataDoc),
  convertToDocx: (dataDoc) =>
    ipcRenderer.invoke("myAPI:convertTo_Docx", dataDoc),
  getListOfConfigs: (dataDoc) =>
    ipcRenderer.invoke("myAPI:get_ListOfConfigs", dataDoc),

  // metodo para exportar la data de la tabla en un excel
  ExportData: (dataDoc) => ipcRenderer.invoke("myAPI:Export_Data", dataDoc),
});

contextBridge.exposeInMainWorld("ApiList", {
  // cargar listas
  loadDataTables: (tabla) =>
    ipcRenderer.invoke("ApiList:load_DataTables", tabla),
});

contextBridge.exposeInMainWorld("ApiLogin", {
  loadLogin: (datosUser) => ipcRenderer.invoke("ApiLogin:login", datosUser),
  loadModules: (perfil) => ipcRenderer.invoke("ApiLogin:Load_Modules", perfil),
  changeDatabase: (db) => ipcRenderer.invoke("ApiLogin:change_Database", db),
});
