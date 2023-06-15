import {
  app,
  BrowserWindow,
  nativeTheme,
  ipcMain,
  ipcRenderer,
} from "electron";
const PDFWindow = require("electron-pdf-window");
import path from "path";
import os from "os";
const sql = require("mssql");
// const html_to_pdf = require("html-pdf-node");
// const pdf = require("pdf-creator-node");
// const xl = require("excel4node");

let sqlConfig = {
  user: "sa",
  password: "Minecraft123",
  database: "ParroquiaBackup",
  server: "GAMINGUZMI\\SERVERSANTI",
  //server: "DESKTOP-6BM9I17\\SQLEXPRESS",
  /* pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  },*/
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

// needed in case process is undefined under Linux
const platform = process.platform || os.platform();

try {
  if (platform === "win32" && nativeTheme.shouldUseDarkColors === true) {
    require("fs").unlinkSync(
      path.join(app.getPath("userData"), "DevTools Extensions")
    );
  }
} catch (_) {}

let mainWindow;

function createWindow() {
  /* Initial window options*/
  mainWindow = new BrowserWindow({
    icon: path.resolve(__dirname, "icons/icon.png"), // tray icon
    width: 1300,
    height: 659,
    useContentSize: true,
    webPreferences: {
      contextIsolation: true,
      sandbox: true,
      // More info: /quasar-cli/developing-electron-apps/electron-preload-script
      //preload: path.resolve(__dirname, process.env.QUASAR_ELECTRON_PRELOAD),
      preload: path.resolve(__dirname, "electron-preload.js"),
      nodeIntegration: true,
    },
  });

  mainWindow.loadURL(process.env.APP_URL);

  //mainWindow.loadFile("C:Users/santi/Desktop/Presta/prueba.pdf");

  if (process.env.DEBUGGING) {
    // if on DEV or Production with debug enabled
    mainWindow.webContents.openDevTools();
  } else {
    // we're on production; no access to devtools pls
    mainWindow.webContents.on("devtools-opened", () => {
      mainWindow.webContents.closeDevTools();
    });
  }

  mainWindow.on("closed", () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  if (platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (mainWindow === null) {
    createWindow();
  }
});

function openPdf(fileRoute) {
  let ventana = null;
  ventana = new BrowserWindow({
    icon: path.resolve(__dirname, "icons/icon.png"), // tray icon
    width: 1300,
    height: 659,
    useContentSize: true,
  });
  ventana.loadURL("file:///" + fileRoute);
  //ventana.webContents.print();

  // const win = new PDFWindow({
  //   width: 800,
  //   height: 600,
  // });
  // console.log("la ruta actual es" + os.homedir());
  // win.loadURL("file:///C:/Users/santi/Desktop/prueba.pdf");
  ventana.webContents.on("did-finish-load", () => {
    ventana.webContents.print();
  });
}
//#region Api login

// ********** API DE LOGIN
ipcMain.handle("ApiLogin:login", async (ev, arg) => {
  console.log("Los datos son", arg.user);
  try {
    let { user, clave } = arg;
    let data = await sql.connect(sqlConfig);
    if (data.connected == true) {
      let request = new sql.Request();
      request.input("Usuario", sql.VARCHAR(50), user);
      request.input("Clave", sql.VARCHAR(50), clave);
      let exec = await request.execute("BD_Get_Login");
      data.close();
      return exec.recordsets[0];
    }
  } catch (err) {
    return { isError: true, errorMessage: "Apilogin " + err };
  }
});

//#endregion

ipcMain.handle("myAPI:Load_Modules", async (ev, IdPerfil) => {
  console.log("Load Modules", IdPerfil);
  try {
    let data = await sql.connect(sqlConfig);
    if (data.connected == true) {
      let request = new sql.Request();
      request.input("IdPerfil", sql.Int, IdPerfil);
      let exec = await request.execute("BD_Get_ModulosPerfil");
      data.close();
      return exec.recordsets[0];
    }
  } catch (err) {
    return { isError: true, errorMessage: "Apilogin " + err };
  }
});

ipcMain.handle("myAPI:load_Ministros", async () => {
  try {
    let data = await sql.connect(sqlConfig);
    if (data.connected == true) {
      let request = new sql.Request();
      let exec = await request.execute("BD_Get_Lists_Ministros");
      data.close();
      return exec.recordsets;
    }
  } catch (err) {
    return { isError: true, errorMessage: "Api_DoyFe " + err };
  }
});

ipcMain.handle("myAPI:load_Firmantes", async () => {
  try {
    let data = await sql.connect(sqlConfig);
    if (data.connected == true) {
      let request = new sql.Request();
      let exec = await request.execute("Wp_Get_ListaMinistros");
      data.close();
      return exec.recordsets[0];
    }
  } catch (err) {
    return { isError: true, errorMessage: "API_load_Firmantes " + err };
  }
});

// ****************    METODO DE INSERCION **************-----------------------
ipcMain.handle("myAPI:ins_Record", async (ev, arg, tabla) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp("BD_Ins_" + tabla);
    arg = JSON.parse(arg);
    console.log(arg, tabla);
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      parametersIn.map((e) => {
        console.log(e["ParameterN"]);
        console.log(getTypeData(e["Type"], e["max_length"]));
        console.log(arg[e["ParameterN"]]);
        request.input(
          e["ParameterN"],
          getTypeData(e["Type"], e["max_length"]),
          arg[e["ParameterN"]]
        );
      });
      let exec = await request.execute("BD_Ins_" + tabla);
      console.log(exec);
      conn.close();
      return exec.recordset[0]["MSJ"];
    }
  } catch (err) {
    return { isError: true, errorMessage: "Apilogin " + err };
  }
});

// ****************    METODO DE ACTUALIZACION **************-----------------------
ipcMain.handle("myAPI:upd_Record", async (ev, arg, tabla) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp("BD_Upd_" + tabla);
    arg = JSON.parse(arg);
    console.log(arg, tabla);
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      parametersIn.map((e) => {
        console.log(e["ParameterN"]);
        console.log(getTypeData(e["Type"], e["max_length"]));
        console.log(arg[e["ParameterN"]]);
        request.input(
          e["ParameterN"],
          getTypeData(e["Type"], e["max_length"]),
          arg[e["ParameterN"]]
        );
      });
      let exec = await request.execute("BD_Upd_" + tabla);
      console.log(exec);
      conn.close();
      return exec.recordset[0][""];
    }
  } catch (err) {
    return { isError: true, errorMessage: "Apilogin " + err };
  }
});

//************** METODOS DE INACTIVACION ********************* */
ipcMain.handle("myAPI:Invt_Record", async (ev, data) => {
  try {
    let { Id, Sp } = data;
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Id", sql.Int, Id);
      let exec = await request.execute(Sp);
      conn.close();
      return exec.recordsets[0];
    }
  } catch (err) {
    return { isError: true, errorMessage: "Invt_record " + err };
  }
});

//************** Metodo que consigue el html del documento ********************* */
ipcMain.handle("myAPI:Get_DocumentoHtml", async (ev, Tabla, Id) => {
  try {
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Tabla", sql.VarChar(50), Tabla);
      request.input("Id", sql.Int, Id);
      let exec = await request.execute("BD_Get_Documento");
      conn.close();
      //console.log(exec);
      return exec.recordset[0];
    }
  } catch (err) {
    return { isError: true, errorMessage: "BD_Get_Documento " + err };
  }
});

//************** Metodo que consigue la lista de configuraciones ********************* */
ipcMain.handle("myAPI:get_ListOfConfigs", async (ev) => {
  try {
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      let exec = await request.execute("BD_Get_Lists_Configs");
      conn.close();
      return exec.recordsets;
    }
  } catch (err) {
    return { isError: true, errorMessage: "BD_Get_Lists_Configs " + err };
  }
});

//************* actualizaer configuraciones ************/
ipcMain.handle("myAPI:upd_VariablesGlobales", async (ev, values) => {
  try {
    let { Id, Nombre, Valor } = JSON.parse(values);
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Id", sql.Int, Id);
      request.input("Valor", sql.VarChar(50), Valor);
      let exec = await request.execute("BD_Upd_VariablesGlobales");
      conn.close();
      return exec.recordset;
    }
  } catch (err) {
    return { isError: true, errorMessage: "BD_Get_Lists_Configs " + err };
  }
});

ipcMain.handle("myAPI:upd_ShortCuts", async (ev, values) => {
  try {
    let { Id, Nombre, Valor } = JSON.parse(values);
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Id", sql.Int, Id);
      request.input("Valor", sql.VarChar(50), Valor);
      let exec = await request.execute("BD_Upd_ShortCuts");
      conn.close();
      return exec.recordset;
    }
  } catch (err) {
    return { isError: true, errorMessage: "BD_Get_Lists_Configs " + err };
  }
});

// *** metodo para ABRIR VENTANA DE IMPERESION ***\\

ipcMain.handle("myAPI:OpenWindow", async (ev, data) => {
  try {
    let { Id, Sp } = data;
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Id", sql.Int, Id);
      let exec = await request.execute(Sp);
      conn.close();
      return exec.recordsets[0];
    }
  } catch (err) {
    return { isError: true, errorMessage: "Invt_record " + err };
  }
});

ipcMain.handle("myAPI:Export_Data", async (ev, tabla) => {
  try {
    if (!tabla) return "Error - No Data to search";
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Tabla", sql.VarChar(20), tabla);
      let exec = await request.execute("BD_GetData_FromTable");
      conn.close();
      let datos = exec.recordsets[0];
      let headers = Object.keys(datos[0]);
      let msj = await exportData(headers, datos, tabla);
      return msj;
    }
  } catch (err) {
    return { isError: true, errorMessage: "Fn_Export_Data " + err };
  }
});

ipcMain.handle("myAPI:GoTo_DocumentoPdf", async (ev, arg) => {
  console.log("Los datos son", arg);
  try {
    let { Html_Body, Html_Footer, Html_Header, Nombre } = JSON.parse(arg);
    let nombre =
      Nombre != null && Nombre ? Nombre + ".pdf" : "dataPdf_tmp" + "_data.pdf";
    let route = os.homedir() + "/Documents/" + nombre;
    console.log("la ruta es :", route);
    var cssb = [];
    cssb.push("<style>");
    cssb.push("*{font-family: Arial, Helvetica, sans-serif;font-size: 12x;}");
    // cssb.push(
    //   ".header { font-size:10px;background-color:#f00; z-index:1000000;width:100%;text-align:center;}"
    // );
    cssb.push(
      ".footer { font-size:10px;background-color:#f00; z-index:1000000;width:100%;text-align:center}"
    );
    cssb.push("</style>");
    const css = cssb.join("");
    let opciones = {
      //formato: "A4",
      formato: "Folio",
      //path: "C:Users/santi/Desktop/prueba.pdf",
      path: route,
      displayHeaderFooter: true,
      headerTemplate: css + Html_Header,
      footerTemplate: css + Html_Footer,
      margin: {
        bottom: 80, // minimum required for footer msg to display
        left: 35,
        right: 20,
        top: 120,
      },
    };
    let file = { content: Html_Header + Html_Body };
    const html_to_pdf = require("html-pdf-node");
    html_to_pdf.generatePdf(file, opciones).then((pdfBuffer) => {
      console.log("PDF Buffer:-", pdfBuffer);
      openPdf(route);
    });
  } catch (err) {
    return { isError: true, errorMessage: "GoTo_DocumentoPdf " + err };
  }
});

ipcMain.handle("myAPI:GoTo_DocumentoPdf2", async (ev, arg) => {
  console.log("Los datos son", arg);
  const pdf = require("pdf-creator-node");
  try {
    let { Html_Body, Html_Footer, Html_Header, Nombre } = JSON.parse(arg);
    var options = {
      format: "Legal",
      orientation: "portrait",
      border: "0mm",
      header: {
        border: "0cm",
        height: "30mm",
        contents: Html_Header,
      },
      footer: {
        height: "15mm",
        contents: {
          default: Html_Footer, // fallback value
        },
      },
      body: {
        margin: "10cm",
        border: "15cm",
      },
    };
    let nombre =
      Nombre != null && Nombre ? Nombre + ".pdf" : "dataPdf_tmp" + "_data.pdf";
    let route = os.homedir() + "/Documents/" + nombre;
    console.log("la ruta es :", route);
    var document = {
      html: Html_Body,
      data: {},
      path: route,
      border: "30mm",
      type: "",
    };

    pdf
      .create(document, options)
      .then((res) => {
        console.log("Se ha creado exitosamente");
        openPdf(route);
      })
      .catch((error) => {
        console.error(error);
      });
  } catch (err) {
    return { isError: true, errorMessage: "GoTo_DocumentoPdf " + err };
  }
});

// APILIST
ipcMain.handle("ApiList:load_DataTables", async (ev, arg) => {
  try {
    let data = await sql.connect(sqlConfig);
    if (data.connected == true) {
      let request = new sql.Request();
      let sp = "BD_Get_Lists_" + arg;
      let exec = await request.execute(sp);
      data.close();
      return exec.recordsets;
    }
  } catch (err) {
    return { isError: true, errorMessage: "BD_Get_Lists_" + arg + " - " + err };
  }
});

function exportData(headers, datos, tabla) {
  return new Promise((res, rej) => {
    const xl = require("excel4node");
    const wb = new xl.Workbook();
    const ws = wb.addWorksheet("Worksheet Name");
    const data = datos;
    const headingColumnNames = headers;
    //Write Column Title in Excel file
    let headingColumnIndex = 1;
    headingColumnNames.forEach((heading) => {
      ws.cell(1, headingColumnIndex++).string(heading);
    });
    //Write Data in Excel file
    let rowIndex = 2;
    data.forEach((record) => {
      let columnIndex = 1;
      Object.keys(record).forEach((columnName) => {
        ws.cell(rowIndex, columnIndex++).string(record[columnName]);
      });
      rowIndex++;
    });
    let route = os.homedir() + "/desktop/" + tabla + "_data.xlsx";
    //wb.write("C:Users/santi/Desktop/data.xlsx");
    wb.write(route);
    res(route);
  });
}

function getParametersSp(Sp) {
  return new Promise(async (resolve) => {
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Sp", sql.VarChar(50), Sp);
      let exec = await request.execute("BD_Get_Lists_Parameters");
      conn.close();
      resolve(exec.recordset);
    }
  });
}

function getTypeData(dato, longitud) {
  if (dato == "int") return sql.Int;
  else if (dato == "varchar")
    return sql.VarChar(longitud == -1 ? "max" : longitud);
  else if (dato == "nvarchar")
    return sql.NVarChar(longitud == -1 ? "max" : longitud);
}
